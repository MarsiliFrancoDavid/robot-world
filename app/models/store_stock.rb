require_relative "stock"

class StoreStock < Stock
    #Takes an order and handles each item individually. Then checkouts the order and based on the checkout result will or won't
    #store the order in the stock.
    def executeOrder(order)

        if(order.status == "incomplete")
            puts "Attempting to complete order with purchaseID: #{order.id}"
        elsif(order.status == "pending")
            puts "Attempting to retry pending order with purchaseID: #{order.id}"
        elsif(order.status == "exchange pending")
            puts "Attempting to exchange order with purchaseID: #{order.id}"
        end

        order.orderItems.each do | item |
            handleItem(item)
        end

        order = order.checkout


        if(order.status == "complete" || order.status == "lost sale" || order.status == "lost exchange")
            order.stock_id = self.id
            order.save
        end

        begin
            if(!self.save)
                puts "An error has ocurred purchasing a car in the #{self.name}"
                puts self.errors.full_messages
            end
        rescue StandardError => e
            print e
        end

        order
    end


    #take an item of an order and tries to get a car in exchange, if no stock is encountered, return false
    def handleItem(item)
        puts "Attempting to buy a #{item.year} #{item.car_model_name}, purchaseID : #{item.order.id}"

        result = self.cars.joins(:car_model).where('car_models.car_model_name' => item.car_model_name , 'car_models.year' => item.year).limit(1)

        if(result.length > 0)
            result = result.first
            puts "Stock encounterd for item with ID #{item.id}"
            item.engine_number = result.id
            self.cars.delete(result) 
            begin
                if(!item.save)
                    puts "An error ocurred saving item with ID: #{item.id}"
                end
            rescue StandardError => e
                print e
            end
        else
            puts "We didn't find stock for item with ID #{item.id} for model #{item.year} #{item.car_model_name} of order with purchaseID: #{item.order.id}"
        end
    end

    #When an order wants to be changed, the car returns to this stock
    #and the withdraw operation starts again
    def exchangeCar(order)
        order.orderItems.each do | item |
            if(item != false)
                if(item.engine_number)
                    begin
                        returnedCar = Car.where('id = ?',item.engine_number)
                        if(returnedCar.length > 0)
                            self.cars << returnedCar.first
                        end
                    rescue StandardError => e
                        print e
                    end
                end
                item.engine_number = nil
                if(!item.save)
                    puts "An error has ocurred trying to erase the engine_number from an exchange order"
                    puts item.errors.full_messages
                end
            end
        end
        
        return self.executeOrder(order)
    end
end

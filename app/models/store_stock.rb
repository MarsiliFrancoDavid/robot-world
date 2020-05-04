require_relative "stock"

class StoreStock < Stock
    #Takes an order and handles each item individually. It all items were satisfied, it change the order status to complete and gives
    #it a completed_date. If not, it"s set as pending and the robot buyer will try later to fulfill the order.
    def executeOrder(order)
        result = []

        order.orderItems.each do | item |
            result << handleItem(item)
        end

        if (!result.include?(false))
            order.status = "complete"
            order.completed_date = Time.zone.today
            self.orders << order
        end

        begin
            if(!self.save)
                puts "An error has ocurred purchasing a car in the #{self.name}"
                puts self.errors.full_messages
            end
        rescue StandardError => e
            print e
        end

        result
    end


    #take an item of an order and tries to get a car in exchange, if no stock is encountered, return false
    def handleItem(item)
        result = false

        index = 0

        puts "Attempting to buy a #{item.year} #{item.model_name}, purchaseID : #{item.order.id}"

        while (index < self.cars.length && result == false) do
            if(self.cars[index].car_model.model_name == item.model_name && self.cars[index].car_model.year == item.year)
                result = index
                item.engine_number = self.cars[index].id
                begin
                    if(!item.save)
                        puts "An error ocurred saving item with ID: #{item.id}"
                    end
                rescue StandardError => e
                    print e
                end
            end
            index += 1
        end

        if(result == false)
            puts "We didn't find stock for item with ID #{item.id} for model #{item.year} #{item.model_name} of order with purchaseID: #{item.order.id}"
        else
            puts "Stock encounterd for item with ID #{item.id}"
            result = self.cars[result]
            self.cars.delete(result) 
        end

        result
    end

    #When an order has been retried a maximum amount of times or the exchanged order
    #doesn't find the new model wanted available, the sale is considered as lost
    def acceptCarSaleLost(order)
        if(order.status == "pending")
            order.status = "lost sale"
        elsif(order.status == "exchange pending")
            order.status = "lost exchange"
        end

        order.completed_date = Time.zone.today

        begin
            if(!order.save)
                puts "An error ocurred saving order in the acceptCarSaleLost function with purchaseID: #{order.id}"
            end
        rescue StandardError => e
            print e
        end

        self.orders << order

        begin
            if(!self.save)
                puts "An error has ocurred accepting a lost car sale in the #{self.name}"
                puts self.errors.full_messages
            end
        rescue StandardError => e
            print e
        end
    end

    #When an order wants to be changed, the car returns to this stock
    #and the withdraw operation starts again
    def exchangeCar(order)
        order.orderItems.each do | item |
            if(item != false)
                returnedCar = Car.find(item.engine_number)
                self.cars << returnedCar
            end
        end
        
        return result = self.executeOrder(order)
    end
end

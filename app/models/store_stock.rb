require_relative "stock"

class StoreStock < Stock
    #Takes an order and handles each item individually. Then checkouts the order and based on the checkout result will or won't
    #store the order in the stock.
    def execute_order(order)
        action = "Do Nothing"

        case order.get_status

        when :incomplete
            action = "complete order"
        when :pending
            action = "retry pending order"
        when :exchange_pending
            action = "exchange order"
        end

        puts "Attempting to #{action} with purchaseID: #{order.id}" 

        order.orderItems.each do | item |
            if(item.engine_number.nil?)
                handle_item(item)
            end
        end

        order = order.checkout


        if(order.get_status == :complete || order.get_status == :lost_sale || order.get_status == :lost_exchange)
            order.stock_id = self.id
            order.save
        end

        begin
            if(!self.save)
                puts "An error has ocurred purchasing a car in the #{self.name}"
                puts self.errors.full_messages
            end
        rescue StandardError => e
            Rails.logger.error e
        end

        order
    end


    #take an item of an order and tries to get a car in exchange, if no stock is encountered, return false
    def handle_item(item)
        puts "Attempting to buy a #{item.year} #{item.car_model_name}, purchaseID : #{item.order.id}"

        result = self.cars.with_model_name(item.car_model_name).with_model_year(item.year).first

        if(!result.nil?)
            puts "Stock encounterd for item with ID #{item.id}"
            item.engine_number = result.id
            self.cars.delete(result) 
            begin
                if(!item.save)
                    puts "An error ocurred saving item with ID: #{item.id}"
                end
            rescue StandardError => e
                Rails.logger.error e
            end
        else
            puts "We didn't find stock for item with ID #{item.id} for model #{item.year} #{item.car_model_name} of order with purchaseID: #{item.order.id}"
        end
    end

    #When an order wants to be changed, the car returns to this stock if it still exists
    #and the withdraw operation starts again
    def exchange_car(order)
        order.orderItems.each do | item |
            if(item != false)
                begin
                    returned_car = Car.find_by(id: item.engine_number)
                    if(!returned_car.nil?)
                        self.cars << returned_car
                    end
                rescue StandardError => e
                    Rails.logger.error e
                end
                item.engine_number = nil
                if(!item.save)
                    puts "An error has ocurred trying to erase the engine_number from an exchange order"
                    puts item.errors.full_messages
                end
            end
        end
        
        return self.execute_order(order)
    end
end

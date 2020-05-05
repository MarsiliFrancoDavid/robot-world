namespace :robot_buyer do
    desc "Robot buyer tasks"

    task buy_cars: [:environment] do
        car_models = CarModel.all
        store_stock = StoreStock.find_by name: "Store Stock"
        if(car_models.length > 0 && store_stock != nil)
            buy_pending_prob = (ENV["PERCENTAGE_TO_ASK_ABOUT_PENDING_CARS"] == nil ? 20 : ENV["PERCENTAGE_TO_ASK_ABOUT_PENDING_CARS"].to_i)
            max_retries = (ENV["MAX_RETRIES_ON_PENDING_CARS"] == nil ? 3 : ENV["MAX_RETRIES_ON_PENDING_CARS"].to_i)

            pending_orders = Array.new(Order.where('status = ? AND retries < ?','pending',max_retries))

            rand(0..10).times do
                begin
                    model = car_models.sample
                    order = Order.create
                    item = OrderItem.create(car_model_name:model.car_model_name,year:model.year,price:model.price,cost_price:model.cost_price,order_id: order.id)
                    order.orderItems << item

                    order = store_stock.execute_order(order)

                    #If the possible cars turns to be an array with actual car objects, the order was already declared completed, saved,
                    #the car disassociated from the stock and it now belongs to the robot buyer. If it isn't, it will be stored
                    #as a pending order and retried after.
                    if(order.get_status == :pending)
                        pending_orders << order
                    end
                rescue StandardError => e
                    print e
                end
            end

            # based in existant pending orders and a probability, the robot buyer will retry a maximum amount
            # of times to get the order completed, if it's maxed out, the robot will stop trying to get it completed.
            if (pending_orders.length > 0 && rand(100) < buy_pending_prob)
                pending_orders.each do | order |
                    begin
                        store_stock.execute_order(order)
                    rescue StandardError => e
                        print e
                    end
                end
            end
        else
            puts "There's no car models nor stock on the database for the robot buyer to work with."
        end
    end


    task exchange_cars: [:environment] do
        exchange_amount_in_wave = (ENV["EXCHANGE_AMOUNT_IN_EXCHANGE_WAVE"] == nil ? 3 : ENV["EXCHANGE_AMOUNT_IN_EXCHANGE_WAVE"].to_i)
        completed_orders = Array.new(Order.where('in_guarantee = ? AND status = ?',true,'complete'))
        exchange_pending_orders = Array.new(Order.where('status = ?','exchange pending'))
        car_models = CarModel.all
        store_stock = StoreStock.find_by name: "Store Stock"
        exchangedCars = Array.new

        #based on the orders that are completed and on the amount wanted to be exchanged in each
        #exchange wave, this process will get an amount of completed orders, change their status to exchange pending
        #and ensure that the new model needed in every order item is different than the previous one.
        if(completed_orders.length >= exchange_amount_in_wave)
            exchange_amount_in_wave.times do
                exchange_order = completed_orders.sample
                completed_orders.delete(exchange_order)
                exchange_order.status = :exchange_pending

                exchange_order.orderItems.each do | item |
                    different_car_models = Array.new(car_models.select{ | model | model.car_model_name != item.car_model_name && model.year != item.year })

                    different_model = different_car_models.sample

                    item.car_model_name = different_model.car_model_name
                    item.year = different_model.year
                    item.price = different_model.price
                    item.cost_price = different_model.cost_price

                    begin
                        if(!item.save)
                            puts "An error has ocurred trying to save an item planned to be exchanged"
                            puts exchange_order.errors.full_messages
                        end
                    rescue StandardError => e
                        print e
                    end
                end

                exchange_order.stock_id = nil
                exchange_order.completed_date = nil
                exchange_order.retries = 0

                begin
                    if(!exchange_order.save)
                        puts "An error has ocurred trying to save an order planned to be exchanged"
                        puts exchange_order.errors.full_messages
                    end
                rescue StandardError => e
                    print e
                end
                exchange_pending_orders << exchange_order
            end
        end

        #in the exchange operation, the robot buyer will try to exchange the order one time only
        #and if the model isn't available, it will cease to want the car/s and the factory will
        #declare that order as a lost sale.
        if(exchange_pending_orders.length > 0)
            exchange_pending_orders.each do | order |
                store_stock.exchange_car(order)
            end
        end
    end
end

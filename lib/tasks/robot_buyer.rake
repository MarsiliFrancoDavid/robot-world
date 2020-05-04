namespace :robot_buyer do
    desc "Robot buyer tasks"

    task buy_cars: [:environment] do
        carModels = CarModel.all
        storeStock = StoreStock.find_by name: "Store Stock"
        if(carModels.length > 0 && storeStock != nil)
            buyPendingProb = (ENV["PERCENTAGE_TO_ASK_ABOUT_PENDING_CARS"] == nil ? 20 : ENV["PERCENTAGE_TO_ASK_ABOUT_PENDING_CARS"].to_i)
            maxRetries = (ENV["MAX_RETRIES_ON_PENDING_CARS"] == nil ? 3 : ENV["MAX_RETRIES_ON_PENDING_CARS"].to_i)

            #each time I execute the loop, I need to refresh this array because the previous orders that were in guarantee still
            #now may not be.
            pendingOrders = Array.new(Order.where('status = ? AND retries < ? AND in_guarantee = ?','pending',maxRetries,true))

            rand(0..10).times do
                begin
                    model = carModels.sample
                    order = Order.create
                    item = OrderItem.create(car_model_name:model.car_model_name,year:model.year,price:model.price,cost_price:model.cost_price,order_id: order.id)
                    order.orderItems << item

                    order = storeStock.executeOrder(order)

                    #If the possible cars turns to be an array with actual car objects, the order was already declared completed, saved,
                    #the car disassociated from the stock and it now belongs to the robot buyer. If it isn't, it will be stored
                    #as a pending order and retried after.
                    if(order.status == "pending")
                        pendingOrders << order
                    end
                rescue StandardError => e
                    print e
                end
            end

            # based in existant pending orders and a probability, the robot buyer will retry a maximum amount
            # of times to get the order completed, if it's maxed out, the robot will stop trying to get it completed.
            if (pendingOrders.length > 0 && rand(100) < buyPendingProb)
                pendingOrders.each do | order |
                    begin
                        storeStock.executeOrder(order)
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
        exchangeAmountInWave = (ENV["EXCHANGE_AMOUNT_IN_EXCHANGE_WAVE"] == nil ? 3 : ENV["EXCHANGE_AMOUNT_IN_EXCHANGE_WAVE"].to_i)
        completedOrders = Array.new(Order.where('in_guarantee = ? AND status = ?',true,'complete'))
        exchangePendingOrders = Array.new(Order.where('status = ?','exchange pending'))
        carModels = CarModel.all
        storeStock = StoreStock.find_by name: "Store Stock"
        exchangedCars = Array.new

        #based on the orders that are completed and on the amount wanted to be exchanged in each
        #exchange wave, this process will get an amount of completed orders, change their status to exchange pending
        #and ensure that the new model needed in every order item is different than the previous one.
        if(completedOrders.length >= exchangeAmountInWave)
            exchangeAmountInWave.times do
                exchangeOrder = completedOrders.sample
                completedOrders.delete(exchangeOrder)
                exchangeOrder.status = "exchange pending"

                exchangeOrder.orderItems.each do | item |
                    differentCarModels = Array.new(carModels.select{ | model | model.car_model_name != item.car_model_name && model.year != item.year })

                    differentModel = differentCarModels.sample

                    item.car_model_name = differentModel.car_model_name
                    item.year = differentModel.year
                    item.price = differentModel.price
                    item.cost_price = differentModel.cost_price

                    begin
                        if(!item.save)
                            puts "An error has ocurred trying to save an item planned to be exchanged"
                            puts exchangeOrder.errors.full_messages
                        end
                    rescue StandardError => e
                        print e
                    end
                end

                exchangeOrder.stock_id = nil
                exchangeOrder.completed_date = nil
                exchangeOrder.retries = 0

                begin
                    if(!exchangeOrder.save)
                        puts "An error has ocurred trying to save an order planned to be exchanged"
                        puts exchangeOrder.errors.full_messages
                    end
                rescue StandardError => e
                    print e
                end
                exchangePendingOrders << exchangeOrder
            end
        end

        #in the exchange operation, the robot buyer will try to exchange the order one time only
        #and if the model isn't available, it will cease to want the car/s and the factory will
        #declare that order as a lost sale.
        if(exchangePendingOrders.length > 0)
            exchangePendingOrders.each do | order |
                storeStock.exchangeCar(order)
            end
        end
    end
end

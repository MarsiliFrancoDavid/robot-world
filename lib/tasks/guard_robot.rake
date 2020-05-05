require_relative "../modules/SlackMessenger"

include SlackMessenger

namespace :guard_robot do
    desc "Guard robot tasks"

    #Every 30 minutes, the guard robot segregates the cars with deffects from the
    #undeffective cars, then , based on that, they are taken to the store stock or the deffective
    #stock.
    #When the cars are being stored in the deffective stock, the slack alert message is sent
    #as well for each car.
    task move_cars_from_factory_to_store_stock: [:environment] do
        no_deffects_cars = Array.new
        deffective_cars = Array.new

        factory_stock = Stock.find_by name: "Factory Stock"
        store_stock = StoreStock.find_by name: "Store Stock"
        deffective_stock = DeffectiveStock.find_by name: "Deffective Stock"

        if(factory_stock != nil && store_stock != nil)
            factory_stock_cars = factory_stock.withdraw_cars

            puts "#{factory_stock_cars.length} cars substracted from the factory stock"
            if(factory_stock_cars.length > 0)
                puts "Will procede to segregate deffective cars from non deffective ones"
            end
            
            factory_stock_cars.each do | car |
                if(car.is_deffective?)
                    deffective_cars << car
                else
                    no_deffects_cars << car
                end
            end


            begin
                unless(no_deffects_cars.length == 0)
                    store_stock.add_cars(no_deffects_cars)
                    puts "#{no_deffects_cars.length} out of #{factory_stock_cars.length} cars were found as non deffective and moved to the store stock"
                end
            rescue StandardError => e
                Rails.logger.error e
            end

            begin
                unless(deffective_cars.length == 0)
                    deffective_stock.add_cars(deffective_cars)
                    puts "#{deffective_cars.length} out of #{factory_stock_cars.length} cars were found as deffective and moved to the deffective stock"
                    deffective_cars.each do | car |
                        SlackMessenger::send_message "We're sorry to inform that the car with the engine number #{car.id.to_s} was found deffective and was transported to the deffective stock :cry:"
                    end
                end
            rescue StandardError => e
                Rails.logger.error e
            end

            begin
                retrieved_components = deffective_stock.turn_deffective_cars_into_components
                unless (retrieved_components.nil? || retrieved_components == 0)
                    puts "The deffective cars were destroyed and we retrieved #{retrieved_components} non deffective parts to be used in the future."
                end
            rescue StandardError => e
                Rails.logger.error e
            end
        else
            puts "There's no stocks loaded on the database for the guard robot to work on."
        end
    end
end
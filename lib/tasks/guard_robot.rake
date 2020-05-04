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
        noDeffectsCars = Array.new
        deffectiveCars = Array.new

        factoryStock = Stock.find_by name: "Factory Stock"
        storeStock = StoreStock.find_by name: "Store Stock"
        deffectiveStock = DeffectiveStock.find_by name: "Deffective Stock"

        if(factoryStock != nil && storeStock != nil)
            factoryStockCars = Array.new(factoryStock.withdrawCars)

            puts "#{factoryStockCars.length} cars substracted from the factory stock"
            if(factoryStockCars.length > 0)
                puts "Will procede to segregate deffective cars from non deffective ones"
            end
            
            factoryStockCars.each do | car |
                if(car.deffects.length > 0)
                    deffectiveCars << car
                else
                    noDeffectsCars << car
                end
            end


            begin
                unless(noDeffectsCars.length == 0)
                    storeStock.addCars(noDeffectsCars)
                    puts "#{noDeffectsCars.length} out of #{factoryStockCars.length} cars were found as non deffective and moved to the store stock"
                end
            rescue StandardError => e
                print e
            end

            begin
                unless(deffectiveCars.length == 0)
                    deffectiveStock.addCars(deffectiveCars)
                    puts "#{deffectiveCars.length} out of #{factoryStockCars.length} cars were found as deffective and moved to the deffective stock"
                    deffectiveCars.each do | car |
                        SlackMessenger::send_message "We're sorry to inform that the car with the engine number #{car.id.to_s} was found deffective and was transported to the deffective stock :cry:"
                    end
                end
            rescue StandardError => e
                print e
            end

            begin
                retrievedComponents = deffectiveStock.turnDeffectiveCarsIntoComponents
                unless (retrievedComponents == nil || retrievedComponents == 0)
                    puts "The deffective cars were destroyed and we retrieved #{retrievedComponents} non deffective parts to be used in the future."
                end
            rescue StandardError => e
                print e
            end
        else
            puts "There's no stocks loaded on the database for the guard robot to work on."
        end
    end
end
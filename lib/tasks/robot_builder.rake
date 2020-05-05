require_relative "../../app/models/application_record"
require_relative "../../app/models/car_factory"
require 'json'

namespace :robot_builder do
    desc "Robot builder tasks"

    
    cars_per_min = (ENV["CARS_PRODUCED_PER_MIN"].nil? ? 10 : ENV["CARS_PRODUCED_PER_MIN"].to_i)
    deffective_prob = (ENV["COMPONENT_DEFFECTIVE_PERCENTAGE"].nil? ? 2 : ENV["COMPONENT_DEFFECTIVE_PERCENTAGE"].to_i)
    
    task start_production: [:environment] do
        car_factory = CarFactory.new
        car_models = CarModel.all

        if(car_models.length > 0 )
            components = JSON.parse(ENV["CAR_COMPONENTS"] || '{"wheel":4,"chassis":1,"laser":1,"computer":1,"engine":1,"seat":2}')

            puts "Attempting to start car creation"

            #create a fixed amount of times per minute, cars and their components with a probability to be deffective
            cars_per_min.times do
                begin 
                    car = Car.new

                    car_models.sample.cars << car
                    
                    #Here, based on the components needed, they're created if there's no retrieved component
                    #that can be reused
                    components.each do | key , value |
                        value.to_i.times do
                            retrieved_component = Component.find_by(name:key,is_deffective:false,car_id:nil)
                            if(retrieved_component != nil)
                                car.components << retrieved_component
                            else
                                car.components << Component.create(name:key,is_deffective:rand(100) < deffective_prob)
                            end
                        end
                    end

                    if(!car.save)
                        puts "An error has ocurred saving a new car when starting production"
                        puts car.errors.full_messages
                    end


                    #this will take the car through the whole building process
                    car_factory.start_production(car)
                    
                rescue StandardError => e
                    Rails.logger.error e
                end
            end
            factory_stock = Stock.find_by name: "Factory Stock"

            #after the cars being completed, the robot builder withdraws them from the
            #factory circuit and takes them to the factory store
            factory_stock.add_cars(car_factory.withdraw_completed_cars)

            puts "Total of cars in the factory stock : #{factory_stock.cars.length}"
        else
            puts "There's no CarModels loaded in the database for the robot builder to work with."
        end
    end

    task cleanup: [:environment] do
        #everyday, the orders that are completed, older than yesterday and still in guarantee will now
        #not, so the exchange operation will be invalid
        completed_in_guarantee_orders_before_yesterday = Order.with_status(:complete).completed_before_yesterday.still_in_guarantee

        completed_in_guarantee_orders_before_yesterday.each do | order |
            order.in_guarantee = false
            begin
                if(!order.save)
                    puts "An error has ocurred saving orders after modifying its guarantee attribute in the cleanup"
                    puts order.errors.full_messages
                end
            rescue StandardError => e
                Rails.logger.error e
            end
        end
        #Destroy every car existing in the Factory and Store stock. The ones that don't have
        #an stock associated is because they have an owner now and doesn't correspond to the robot builder
        #to take it from them
        store_stock = StoreStock.find_by(name:"Store Stock")
        factory_stock = Stock.find_by(name:"Factory Stock")
        if(store_stock != nil)
            store_stock.cars.each do | car |
                car.components.delete_all
                begin
                    car.destroy
                rescue StandardError => e
                    Rails.logger.error e
                end
            end
        end

        if(factory_stock != nil)
            factory_stock.cars.each do | car |
                car.components.delete_all
                begin
                    car.destroy
                rescue StandardError => e
                    Rails.logger.error e
                end
            end
        end
    end
end
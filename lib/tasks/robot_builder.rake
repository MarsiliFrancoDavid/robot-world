require_relative "../../app/models/application_record"
require_relative "../../app/models/car_factory"
require 'json'

namespace :robot_builder do
    desc "Robot builder tasks"

    
    carsPerMin = (ENV["pg_cars_produced_per_min"] == nil ? 10 : ENV["pg_cars_produced_per_min"].to_i)
    deffectiveProb = (ENV["pg_carcomponent_deffective_percentage"] == nil ? 2 : ENV["pg_carcomponent_deffective_percentage"].to_i)
    
    task start_production: [:environment] do
        loop do
            carFactory = CarFactory.new
            carModels = CarModel.all

            if(carModels.length > 0 )
                components = JSON.parse((ENV["pg_car_components"] == nil ? '{"wheel":4,"chassis":1,"laser":1,"computer":1,"engine":1,"seat":2}' : ENV["pg_car_components"]))

                puts "Attempting to start car creation"

                #create a fixed amount of times per minute, cars and their components with a probability to be deffective
                carsPerMin.times do
                    begin 
                        car = Car.new

                        carModels.sample.cars << car
                        
                        #Here, based on the components needed, they're created if there's no retrieved component
                        #that can be reused
                        components.each do | key , value |
                            value.to_i.times do
                                retrievedComponent = Component.find_by(name:key,deffective:false,car_id:nil)
                                if(retrievedComponent != nil)
                                    car.components << retrievedComponent
                                else
                                    car.components << Component.create(name:key,deffective:rand(100) < deffectiveProb)
                                end
                            end
                        end

                        if(!car.save)
                            puts "An error has ocurred saving a new car when starting production"
                            puts car.errors.full_messages
                        end

                        #this will take the car through the whole building process
                        carFactory.startProduction(car)
                        
                    rescue StandardError => e
                        print e
                    end
                end
                factoryStock = Stock.find_by name: "Factory Stock"

                #after the cars being completed, the robot builder withdraws them from the
                #factory circuit and takes them to the factory store
                factoryStock.addCars(carFactory.withdrawCompletedCars)
                puts "Total of cars in the factory stock : #{factoryStock.cars.length}"
                sleep (1.minute)
            else
                puts "There's no CarModels loaded in the database for the robot builder to work with."
            end
        end
    end

    task cleanup: [:environment] do
        loop do
            sleep(1.day)
            #everyday, the orders that are completed, older than yesterday and still in guarantee will now
            #not, so the exchange operation will be invalid
            completedOrders = Array.new(Order.all).select { | order | order.inGuarantee && order.status == "complete" }
            completedOrders.each do | order |
                if(order.completedDate < Time.zone.yesterday)
                    order.inGuarantee = false
                    begin
                        if(!order.save)
                            puts "An error has ocurred saving orders after modifying its guarantee attribute in the cleanup"
                            puts order.errors.full_messages
                        end
                    rescue StandardError => e
                        print e
                    end
                end
            end
            #Destroy every car existing in the Factory and Store stock. The ones that don't have
            #an stock associated is because they have an owner now and doesn't correspond to the robot builder
            #to take it from them
            storeStock = StoreStock.find_by(name:"Store Stock")
            factoryStock = Stock.find_by(name:"Factory Stock")
            if(storeStock != nil)
                storeStock.cars.each do | car |
                    car.components.each do | component |
                        car.components.delete(component)
                    end
                    begin
                        car.destroy
                    rescue StandardError => e
                        print e
                    end
                end
            end

            if(factoryStock != nil)
                factoryStock.cars.each do | car |
                    car.components.each do | component |
                        car.components.delete(component)
                    end
                    begin
                        car.destroy
                    rescue StandardError => e
                        print e
                    end
                end
            end
        end
    end
end
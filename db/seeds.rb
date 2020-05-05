start_from_scratch = (ENV["START_FROM_SCRATCH"] == nil ? "false" : ENV["START_FROM_SCRATCH"].downcase)
start_from_scratch = start_from_scratch == "true"
if (start_from_scratch)
    begin
        Component.destroy_all
        Car.destroy_all
        CarModel.destroy_all
        OrderItem.destroy_all
        Order.destroy_all
        Stock.destroy_all
        puts "Succesfully destroyed all car models, cars , car components, stocks and orders with its order items that previously existed"
    rescue StandardError => e
        print e
    end

    begin
        Stock.create(name: "Factory Stock", type: "Stock")
        Stock.create(name: "Store Stock", type: "StoreStock")
        Stock.create(name: "Deffective Stock", type: "DeffectiveStock")
        puts "Succesfully created the Factory, Store and Deffective Stock"
    rescue StandardError => e
        print e
    end
end

begin
    car_models = JSON.parse(ENV["CAR_MODELS"] == nil ? '{"2002":["Audi A7","Alfa Romeo Stelvio"],"2020":["Cadillac CTS","Chevrolet Cruze"]}' : ENV["CAR_MODELS"])
    min_price = (ENV["CAR_MIN_PRICE_RANGE"] == nil ? 10000 : ENV["CAR_MIN_PRICE_RANGE"].to_i)
    max_price = (ENV["CAR_MAX_PRICE_RANGE"] == nil ? 20000 : ENV["CAR_MAX_PRICE_RANGE"].to_i)
    min_cost = (ENV["CAR_MIN_COSTPRICE_RANGE"] == nil ? 1000 : ENV["CAR_MIN_COSTPRICE_RANGE"].to_i)
    max_cost = (ENV["CAR_MAX_COSTPRICE_RANGE"] == nil ? 5000 : ENV["CAR_MAX_COSTPRICE_RANGE"].to_i)

    car_models.each do | key , value |
        if(value.length > 0)
            value.each do | model |
                car_model = CarModel.new(car_model_name: model,year:key.to_i,price: rand(min_price..max_price),cost_price: rand(min_cost..max_cost))
                if(!car_model.save)
                    puts "There was an error saving the new car model #{car_model.year} #{car_model.car_model_name}"
                    puts car_model.errors.full_messages
                else
                    puts "Succesfully created the car model #{car_model.year} #{car_model.car_model_name}"
                end
            end
        end
    end

rescue StandardError => e
    print e
end





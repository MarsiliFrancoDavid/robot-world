startFromScratch = (ENV["pg_start_from_scratch"] == nil ? "false" : ENV["pg_start_from_scratch"].downcase)
startFromScratch = startFromScratch == "true"
if (startFromScratch)
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
    carModels = JSON.parse(ENV["pg_car_models"] == nil ? '{"2002":["Audi A7","Alfa Romeo Stelvio"],"2020":["Cadillac CTS","Chevrolet Cruze"]}' : ENV["pg_car_models"])
    # carGenerations = (ENV["pg_car_generations"] == nil ? [2002,2003,2004,2010,2020] : ENV["pg_car_generations"].split(','))
    min_price = (ENV["pg_car_min_price_range"] == nil ? 10000 : ENV["pg_car_min_price_range"].to_i)
    max_price = (ENV["pg_car_max_price_range"] == nil ? 20000 : ENV["pg_car_max_price_range"].to_i)
    min_cost = (ENV["pg_car_min_costprice_range"] == nil ? 1000 : ENV["pg_car_min_costprice_range"].to_i)
    max_cost = (ENV["pg_car_max_costprice_range"] == nil ? 5000 : ENV["pg_car_max_costprice_range"].to_i)

    carModels.each do | key , value |
        if(value.length > 0)
            value.each do | model |
                carmodel = CarModel.new(modelName: model,year:key.to_i,price: rand(min_price..max_price),costprice: rand(min_cost..max_cost))
                if(!carmodel.save)
                    puts carmodel.errors.full_messages
                else
                    puts "Succesfully created the car model #{carmodel.year} #{carmodel.modelName}"
                end
            end
        end
    end

rescue StandardError => e
    print e
end





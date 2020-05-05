require "rails_helper"

RSpec.describe StoreStock do
    components = JSON.parse(ENV["CAR_COMPONENTS"] || '{"wheel":4,"chassis":1,"laser":1,"computer":1,"engine":1,"seat":2}')

    it "should be able to handle an order exchange from the robot buyer" do
        stock = StoreStock.create(name: "Store Stock", type: "StoreStock")


        #these cars will be returned to the stock
        car_model = CarModel.create(car_model_name: "Toyota Corolla",year: 2000,price: 30000,cost_price: 7600)
        returned_car = Car.new
        components.each do | key , value |
            value.to_i.times do
                returned_car.components << Component.create(name:key,is_deffective:false)
            end
        end
        car_model.cars << returned_car
        returned_car.save

        returned_car2 = Car.new
        car_model.cars << returned_car2
        components.each do | key , value |
            value.to_i.times do
                returned_car2.components << Component.create(name:key,is_deffective:false)
            end
        end
        returned_car2.save


        #after returning the previous car, it will ask for a 1980 Ford Taunus model
        will_exchange_order = Order.create(status: "exchange pending")
        item1 = OrderItem.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500,order_id:will_exchange_order.id,engine_number:returned_car.id)

        #after returning the previous car, it will ask for a 2010 Chevrolet Cruze model
        wont_exchange_order = Order.create(status: "exchange pending")
        item2 = OrderItem.create(car_model_name: "Chevrolet Cruze",year: 2010,price: 27000,cost_price: 3200,order_id:wont_exchange_order.id, engine_number:returned_car2.id)

        #it will be in stock
        car_model2 = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)
        car_in_stock = Car.new
        components.each do | key , value |
            value.to_i.times do
                car_in_stock.components << Component.create(name:key,is_deffective:false)
            end
        end
        car_array = Array.new
        car_model2.cars << car_in_stock
        car_in_stock.save

        car_array << car_in_stock

        stock.add_cars(car_array)

        will_exchange_order = stock.exchange_car(will_exchange_order)
        wont_exchange_order = stock.exchange_car(wont_exchange_order)

        expect(stock.cars.find{| car | car.id == returned_car.id}.id).to eq(returned_car.id)
        expect(stock.cars.find{| car | car.id == returned_car2.id}.id).to eq(returned_car2.id)
        expect(will_exchange_order.get_status).to eq(:complete)
        expect(wont_exchange_order.get_status).to eq(:lost_exchange)
    end

    it "should return an order with pending status if there's no car stock or an order with a complete status if there was, and add the completed order to the stock orders" do
        stock = StoreStock.create(name: "Store Stock", type: "StoreStock")
        order = Order.create
        item = OrderItem.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500,order_id:order.id)
        order.orderItems << item
        order_with_no_stock = Order.create
        item2 = OrderItem.create(car_model_name: "Fiat Punto",year: 2005,price: 30000,cost_price: 2500,order_id:order_with_no_stock.id)

        car_model = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)
        car = Car.new
        components.each do | key , value |
            value.to_i.times do
                car.components << Component.create(name:key,is_deffective:false)
            end
        end
        car_array = Array.new
        car_model.cars << car
        car.save

        car_array << car

        stock.add_cars(car_array)

        order = stock.execute_order(order)
        order_with_no_stock = stock.execute_order(order_with_no_stock)

        expect(order.get_status).to eq(:complete)
        expect(stock.orders.first.id).to eq(order.id)
        expect(order_with_no_stock.get_status).to eq(:pending)
    end
end
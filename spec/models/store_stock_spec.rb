require "rails_helper"

RSpec.describe StoreStock do
    components = JSON.parse((ENV["CAR_COMPONENTS"] == nil ? '{"wheel":4,"chassis":1,"laser":1,"computer":1,"engine":1,"seat":2}' : ENV["CAR_COMPONENTS"]))

    it "should be able to handle an order exchange from the robot buyer" do
        stock = StoreStock.create(name: "Store Stock", type: "StoreStock")


        #these cars will be returned to the stock
        carModel = CarModel.create(car_model_name: "Toyota Corolla",year: 2000,price: 30000,cost_price: 7600)
        returnedCar = Car.new
        components.each do | key , value |
            value.to_i.times do
                returnedCar.components << Component.create(name:key,deffective:false)
            end
        end
        carModel.cars << returnedCar
        returnedCar.save

        returnedCar2 = Car.new
        carModel.cars << returnedCar2
        components.each do | key , value |
            value.to_i.times do
                returnedCar2.components << Component.create(name:key,deffective:false)
            end
        end
        returnedCar2.save


        #after returning the previous car, it will ask for a 1980 Ford Taunus model
        willExchangeOrder = Order.create(status: "exchange pending")
        item1 = OrderItem.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500,order_id:willExchangeOrder.id,engine_number:returnedCar.id)

        #after returning the previous car, it will ask for a 2010 Chevrolet Cruze model
        wontExchangeOrder = Order.create(status: "exchange pending")
        item2 = OrderItem.create(car_model_name: "Chevrolet Cruze",year: 2010,price: 27000,cost_price: 3200,order_id:wontExchangeOrder.id, engine_number:returnedCar2.id)

        #it will be in stock
        carModel2 = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)
        carInStock = Car.new
        components.each do | key , value |
            value.to_i.times do
                carInStock.components << Component.create(name:key,deffective:false)
            end
        end
        carArray = Array.new
        carModel2.cars << carInStock
        carInStock.save

        carArray << carInStock

        stock.addCars(carArray)

        willExchangeOrder = stock.exchangeCar(willExchangeOrder)
        wontExchangeOrder = stock.exchangeCar(wontExchangeOrder)

        expect(stock.cars.find{| car | car.id == returnedCar.id}.id).to eq(returnedCar.id)
        expect(stock.cars.find{| car | car.id == returnedCar2.id}.id).to eq(returnedCar2.id)
        expect(willExchangeOrder.status).to eq("complete")
        expect(wontExchangeOrder.status).to eq("lost exchange")
    end

    it "should return an order with pending status if there's no car stock or an order with a complete status if there was, and add the completed order to the stock orders" do
        stock = StoreStock.create(name: "Store Stock", type: "StoreStock")
        order = Order.create
        item = OrderItem.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500,order_id:order.id)
        order.orderItems << item
        orderWithNoStock = Order.create
        item2 = OrderItem.create(car_model_name: "Fiat Punto",year: 2005,price: 30000,cost_price: 2500,order_id:orderWithNoStock.id)

        carModel = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)
        car = Car.new
        components.each do | key , value |
            value.to_i.times do
                car.components << Component.create(name:key,deffective:false)
            end
        end
        carArray = Array.new
        carModel.cars << car
        car.save

        carArray << car

        stock.addCars(carArray)

        order = stock.executeOrder(order)
        orderWithNoStock = stock.executeOrder(orderWithNoStock)

        expect(order.status).to eq("complete")
        expect(stock.orders.first.id).to eq(order.id)
        expect(orderWithNoStock.status).to eq("pending")
    end
end
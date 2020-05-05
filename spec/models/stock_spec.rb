require "rails_helper"

RSpec.describe Stock do
    components = JSON.parse(ENV["CAR_COMPONENTS"] || '{"wheel":4,"chassis":1,"laser":1,"computer":1,"engine":1,"seat":2}')

    it "should be created when its attributes are passed in properly" do
        stock = Stock.create(name: "Factory Stock", type: "Stock")

        expect(stock.errors.full_messages).to match_array([])
        expect(stock.name).to eq("Factory Stock")
        expect(stock.type).to eq("Stock")
    end

    it "shouldn't be created if name and type attributes aren't present" do
        stock = Stock.create

        expect(stock.errors.full_messages).to match_array(["Name can't be blank", "Type can't be blank"])
    end

    it "shouldn't be destroyed if it has cars or orders referentiating to it" do
        stock = Stock.create(name: "Factory Stock", type: "Stock")
        order = Order.create
        car_model = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)
        car = Car.new
        components.each do | key , value |
            value.to_i.times do
                car.components << Component.create(name:key,is_deffective:false)
            end
        end
        car_model.cars << car
        car.save


        stock.orders << order
        stock.cars << car

        expect{ stock.destroy }.to raise_error ActiveRecord::InvalidForeignKey
    end

    it "should be destroyed if no more cars nor orders referenciate to it" do
        stock = Stock.create(name: "Factory Stock", type: "Stock")

        stock.destroy

        expect{ stock.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it "should associate cars properly" do
        stock = Stock.create(name: "Factory Stock", type: "Stock")
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

        expect(stock.cars.first.id).to eq(car.id)
    end

    it "should disassociate cars properly" do
        stock = Stock.create(name: "Factory Stock", type: "Stock")
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
        returned_cars_array = Array.new(stock.withdraw_cars)

        expect(returned_cars_array.first.id).to eq(car.id)
    end

    it "should return the model stock amount" do
        stock = Stock.create(name: "Factory Stock", type: "Stock")
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

        expect(stock.consult_cars_stock_by_model_name(car.car_model.car_model_name,car.car_model.year)).to eq(1)
    end
end
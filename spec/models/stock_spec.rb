require "rails_helper"

RSpec.describe Stock do
    components = JSON.parse((ENV["CAR_COMPONENTS"] == nil ? '{"wheel":4,"chassis":1,"laser":1,"computer":1,"engine":1,"seat":2}' : ENV["CAR_COMPONENTS"]))

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
        carModel = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)
        car = Car.new
        components.each do | key , value |
            value.to_i.times do
                car.components << Component.create(name:key,deffective:false)
            end
        end
        carModel.cars << car
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

        expect(stock.cars.first.id).to eq(car.id)
    end

    it "should disassociate cars properly" do
        stock = Stock.create(name: "Factory Stock", type: "Stock")
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
        returnedCarsArray = Array.new(stock.withdrawCars)

        expect(returnedCarsArray.first.id).to eq(car.id)
    end

    it "should return the model stock amount" do
        stock = Stock.create(name: "Factory Stock", type: "Stock")
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

        expect(stock.consultCarsStockByModelName(car.car_model.model_name,car.car_model.year)).to eq(1)
    end
end
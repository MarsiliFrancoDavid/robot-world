require "rails_helper"

RSpec.describe CarModel do
    components = JSON.parse((ENV["CAR_COMPONENTS"] == nil ? '{"wheel":4,"chassis":1,"laser":1,"computer":1,"engine":1,"seat":2}' : ENV["CAR_COMPONENTS"]))
    it "should be created when its attributes are passed in properly" do
        carModel = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)
        
        expect(carModel.car_model_name).to eq("Ford Taunus")
        expect(carModel.year).to eq(1980)
        expect(carModel.price).to eq(10000)
        expect(carModel.cost_price).to eq(500)
        expect(carModel.errors.full_messages).to match_array([])
    end

    it "should not be created if car_model_name isn't unique" do
        carModel = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)
        carModel2 = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)

        expect(carModel2.errors.full_messages.first).to eq("car_model_name has already been taken")
    end

    it "should not be created if car_model_name, year, price and cost_price attributes aren't present" do
        carModel = CarModel.create

        expect(carModel.errors.full_messages).to match_array(["car_model_name can't be blank", "Year can't be blank", "Year is not a number", "Price can't be blank", "Price is not a number", "cost_price can't be blank", "cost_price is not a number"])
    end

    it "should not be created if price and cost_price aren't greater than 0" do
        carModel = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 0,cost_price: -10)

        expect(carModel.errors.full_messages).to match_array(["Price must be greater than 0", "cost_price must be greater than 0"])
    end

    it "should not be created if the year is older than the current or less than 0" do
        carModel = CarModel.create(: "Ford Taunus",year: Time.now.year + 1,price: 10000,cost_price: 500)
        carModel2 = CarModel.create(car_model_name: "Ford Taunus",year: 0,price: 10000,cost_price: 500)

        expect(carModel.errors.full_messages.first).to eq("Year must be less than or equal to 2020")
        expect(carModel2.errors.full_messages.first).to eq("Year must be greater than 0")
    end

    it "should be destroyed if no more cars are associated to the model" do
        carModel = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)
        car = Car.new
        components.each do | key , value |
            value.to_i.times do
                car.components << Component.create(name:key,deffective:false)
            end
        end
        carModel.cars << car
        car.save

        carModel.cars.each do | car |
            carModel.cars.delete(car)
        end

        carModel.destroy

        expect{ carModel.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it "shouldn't be destroyed it the record still has cars associated to it" do
        carModel = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)
        car = Car.new
        components.each do | key , value |
            value.to_i.times do
                car.components << Component.create(name:key,deffective:false)
            end
        end
        carModel.cars << car
        car.save

        expect{ carModel.destroy }.to raise_error ActiveRecord::InvalidForeignKey
    end
end
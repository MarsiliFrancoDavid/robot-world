require "rails_helper"

RSpec.describe CarModel do
    components = JSON.parse((ENV["CAR_COMPONENTS"] == nil ? '{"wheel":4,"chassis":1,"laser":1,"computer":1,"engine":1,"seat":2}' : ENV["CAR_COMPONENTS"]))
    it "should be created when its attributes are passed in properly" do
        car_model = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)
        
        expect(car_model.car_model_name).to eq("Ford Taunus")
        expect(car_model.year).to eq(1980)
        expect(car_model.price).to eq(10000)
        expect(car_model.cost_price).to eq(500)
        expect(car_model.errors.full_messages).to match_array([])
    end

    it "should not be created if car_model_name isn't unique" do
        car_model = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)
        car_model2 = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)

        expect(car_model2.errors.full_messages.first).to eq("Car model name has already been taken")
    end

    it "should not be created if car_model_name, year, price and cost_price attributes aren't present" do
        car_model = CarModel.create

        expect(car_model.errors.full_messages).to match_array(["Car model name can't be blank", "Cost price can't be blank", "Cost price is not a number", "Price can't be blank", "Price is not a number", "Year can't be blank", "Year is not a number"])
    end

    it "should not be created if price and cost_price aren't greater than 0" do
        car_model = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 0,cost_price: -10)

        expect(car_model.errors.full_messages).to match_array(["Cost price must be greater than 0", "Price must be greater than 0"])
    end

    it "should not be created if the year is older than the current or less than 0" do
        car_model = CarModel.create(car_model_name: "Ford Taunus",year: Time.now.year + 1,price: 10000,cost_price: 500)
        car_model2 = CarModel.create(car_model_name: "Ford Taunus",year: 0,price: 10000,cost_price: 500)

        expect(car_model.errors.full_messages.first).to eq("Year must be less than or equal to 2020")
        expect(car_model2.errors.full_messages.first).to eq("Year must be greater than 0")
    end

    it "should be destroyed if no more cars are associated to the model" do
        car_model = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)
        car = Car.new
        components.each do | key , value |
            value.to_i.times do
                car.components << Component.create(name:key,is_deffective:false)
            end
        end
        car_model.cars << car
        car.save

        car_model.cars.each do | car |
            car_model.cars.delete(car)
        end

        car_model.destroy

        expect{ car_model.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it "shouldn't be destroyed it the record still has cars associated to it" do
        car_model = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)
        car = Car.new
        components.each do | key , value |
            value.to_i.times do
                car.components << Component.create(name:key,is_deffective:false)
            end
        end
        car_model.cars << car
        car.save

        expect{ car_model.destroy }.to raise_error ActiveRecord::InvalidForeignKey
    end
end
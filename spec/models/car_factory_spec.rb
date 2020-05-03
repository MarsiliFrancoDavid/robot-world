require "rails_helper"

RSpec.describe CarFactory do
    components = JSON.parse((ENV["pg_car_components"] == nil ? '{"wheel":4,"chassis":1,"laser":1,"computer":1,"engine":1,"seat":2}' : ENV["pg_car_components"]))

    it "should have three production lines and a completed cars array existing when created" do
        carFactory = CarFactory.new

        expect(carFactory.completedCars).to match_array([])
        expect(carFactory.assemblyLines).to include(
            "Basic Structure"            => {},
            "Electronic devices"         => {},
            "Painting and final details" => {}
        )
    end

    it "should send down the line a car until it's completed" do
        carFactory = CarFactory.new
        carModel = CarModel.create(modelName: "Ford Taunus",year: 1980,price: 10000,costprice: 500)
        car = Car.new
        components.each do | key , value |
            value.to_i.times do
                car.components << Component.create(name:key,deffective:false)
            end
        end
        carModel.cars << car
        car.save

        carFactory.startProduction(car)
        
        expect(car.completed).to be(true)
        expect(car.stage).to eq("completed")
    end
end
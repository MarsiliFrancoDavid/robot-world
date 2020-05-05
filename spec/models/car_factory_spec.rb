require "rails_helper"

RSpec.describe CarFactory do
    components = JSON.parse((ENV["CAR_COMPONENTS"] == nil ? '{"wheel":4,"chassis":1,"laser":1,"computer":1,"engine":1,"seat":2}' : ENV["CAR_COMPONENTS"]))

    it "should have three production lines and a completed cars array existing when created" do
        car_factory = CarFactory.new

        expect(car_factory.completed_cars).to match_array([])
        expect(car_factory.assembly_lines).to include(
            :basic_structure           => {},
            :electronic_devices         => {},
            :painting_and_final_details => {}
        )
    end

    it "should send down the line a car until it's completed" do
        car_factory = CarFactory.new
        car_model = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)
        car = Car.new
        components.each do | key , value |
            value.to_i.times do
                car.components << Component.create(name:key,deffective:false)
            end
        end
        car_model.cars << car
        car.save

        car_factory.start_production(car)
        
        expect(car.completed).to be(true)
        expect(car.get_stage).to eq(:completed)
    end
end
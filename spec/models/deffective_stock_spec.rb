require "rails_helper"

RSpec.describe DeffectiveStock do
    components = JSON.parse((ENV["CAR_COMPONENTS"] == nil ? '{"wheel":4,"chassis":1,"laser":1,"computer":1,"engine":1,"seat":2}' : ENV["CAR_COMPONENTS"]))

    it "should return the amount of non deffective pieces recovered and destroy the car that had them as well as the defective component/s" do
        stock = DeffectiveStock.create(name: "Deffective Stock", type: "DeffectiveStock")
        car_model = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)
        car = Car.new
        components.each do | key , value |
            value.to_i.times do
                car.components << Component.create(name:key,deffective:rand(100) < 75)
            end
        end
        car_array = Array.new
        car_model.cars << car
        car.save

        car_array << car

        stock.add_cars(car_array)
        
        actually_deffective_comps = car.components.select{ | component | component.deffective}
        should_retrieve = car.components.select{ | component | !component.deffective}.length
        retrieved_components_amount = stock.turn_deffective_cars_into_components

        expect(retrieved_components_amount).to eq(should_retrieve)
        expect{ car.reload }.to raise_error ActiveRecord::RecordNotFound

        actually_deffective_comps.each do | deffectiveComp |
            expect{ deffectiveComp.reload }.to raise_error ActiveRecord::RecordNotFound
        end
    end
end
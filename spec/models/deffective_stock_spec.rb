require "rails_helper"

RSpec.describe DeffectiveStock do
    components = JSON.parse((ENV["CAR_COMPONENTS"] == nil ? '{"wheel":4,"chassis":1,"laser":1,"computer":1,"engine":1,"seat":2}' : ENV["CAR_COMPONENTS"]))

    it "should return the amount of non deffective pieces recovered and destroy the car that had them as well as the defective component/s" do
        stock = DeffectiveStock.create(name: "Deffective Stock", type: "DeffectiveStock")
        carModel = CarModel.create(modelName: "Ford Taunus",year: 1980,price: 10000,costprice: 500)
        car = Car.new
        components.each do | key , value |
            value.to_i.times do
                car.components << Component.create(name:key,deffective:rand(100) < 75)
            end
        end
        carArray = Array.new
        carModel.cars << car
        car.save

        carArray << car

        stock.addCars(carArray)
        
        actuallyDeffectiveComps = car.components.select{ | component | component.deffective}
        shouldRetrieve = car.components.select{ | component | !component.deffective}.length
        retrievedComponentsAmount = stock.turnDeffectiveCarsIntoComponents

        expect(retrievedComponentsAmount).to eq(shouldRetrieve)
        expect{ car.reload }.to raise_error ActiveRecord::RecordNotFound

        actuallyDeffectiveComps.each do | deffectiveComp |
            expect{ deffectiveComp.reload }.to raise_error ActiveRecord::RecordNotFound
        end
    end
end
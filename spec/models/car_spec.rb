require "rails_helper"

RSpec.describe Car do
    components = JSON.parse((ENV["CAR_COMPONENTS"] == nil ? '{"wheel":4,"chassis":1,"laser":1,"computer":1,"engine":1,"seat":2}' : ENV["CAR_COMPONENTS"]))

    it "should be created with default values,an associated car model and its components validated" do
        carModel = CarModel.create(modelName: "Ford Taunus",year: 1980,price: 10000,costprice: 500)
        car = Car.new
        components.each do | key , value |
            value.to_i.times do
                car.components << Component.create(name:key,deffective:false)
            end
        end
        carModel.cars << car
        car.save
        
        expect(carModel.cars.first.id).to be(car.id)
        expect(car.errors.full_messages).to match_array([])
        expect(car.stage).to eq("Uninitialized")
        expect(car.deffects).to match_array([])
        expect(car.completed).to be(false)
    end

    it "should not be created if no car model is associated to the car" do
        car = Car.create

        expect(car.errors.full_messages.first).to eq("Car model must exist")
    end

    it "shouldn't be destroyed if there's components still associated to the car" do
        carModel = CarModel.create(modelName: "Ford Taunus",year: 1980,price: 10000,costprice: 500)
        car = Car.new
        components.each do | key , value |
            value.to_i.times do
                car.components << Component.create(name:key,deffective:false)
            end
        end
        carModel.cars << car
        car.save


        expect{ car.destroy }.to raise_error ActiveRecord::InvalidForeignKey
    end


    it "should be destroyed if no more components are associated to the car" do 
        comp = Component.create(name:"Wheel",deffective:false)
        carModel = CarModel.create(modelName: "Ford Taunus",year: 1980,price: 10000,costprice: 500)
        car = Car.create
        carModel.cars << car
        car.components << comp

        car.components.each do | component |
            car.components.delete(component)
        end

        car.destroy

        expect{ car.reload }.to raise_error ActiveRecord::RecordNotFound
    end
end
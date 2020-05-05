require "rails_helper"

RSpec.describe Car do
    components = JSON.parse(ENV["CAR_COMPONENTS"] || '{"wheel":4,"chassis":1,"laser":1,"computer":1,"engine":1,"seat":2}')

    it "should be created with default values,an associated car model and its components validated" do
        car_model = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)
        car = Car.new
        components.each do | key , value |
            value.to_i.times do
                car.components << Component.create(name:key,is_deffective:false)
            end
        end
        car_model.cars << car
        car.save
        
        expect(car_model.cars.first.id).to be(car.id)
        expect(car.errors.full_messages).to match_array([])
        expect(car.get_stage).to eq(:uninitialized)
        expect(car.is_deffective?).to be(false)
        expect(car.completed).to be(false)
    end

    it "should not be created if no car model is associated to the car" do
        car = Car.create

        expect(car.errors.full_messages.first).to eq("Car model must exist")
    end

    it "shouldn't be destroyed if there's components still associated to the car" do
        car_model = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)
        car = Car.new
        components.each do | key , value |
            value.to_i.times do
                car.components << Component.create(name:key,is_deffective:false)
            end
        end
        car_model.cars << car
        car.save


        expect{ car.destroy }.to raise_error ActiveRecord::InvalidForeignKey
    end


    it "should be destroyed if no more components are associated to the car" do 
        comp = Component.create(name:"Wheel",is_deffective:false)
        car_model = CarModel.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500)
        car = Car.create
        car_model.cars << car
        car.components << comp

        car.components.each do | component |
            car.components.delete(component)
        end

        car.destroy

        expect{ car.reload }.to raise_error ActiveRecord::RecordNotFound
    end
end
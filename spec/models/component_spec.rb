require "rails_helper"

RSpec.describe Component do
    it "should not be created if name attribute isn't present" do
        comp = Component.create

        expect(comp.errors.full_messages.first).to eq("Name can't be blank")
    end

    it "should display data correctly when assigned a name and a deffective boolean" do
        comp = Component.create(name:"Wheel",is_deffective:false)

        expect(comp.name).to eq("Wheel")
        expect(comp.is_deffective).to be(false)
    end

    it "should become associated to a car when specified" do
        comp = Component.create(name:"Wheel",is_deffective:false)
        car = Car.create
        car.components << comp

        expect(car.components.first.id).to be(comp.id)
    end

    it "should be destroyed with no dependencies restriction" do
        comp = Component.create(name:"Wheel",is_deffective:false)

        comp.destroy

        expect{ comp.reload }.to raise_error ActiveRecord::RecordNotFound
    end
end
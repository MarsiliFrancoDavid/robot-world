require 'rails_helper'

RSpec.describe OrderItem do
   it "should be created if its attributes with no default value are properly provided" do
        order = Order.create
        item = OrderItem.create(modelName: "Ford Taunus",year: 1980,price: 10000,costprice: 500,order_id:order.id)
        order.orderItems << item

        expect(item.modelName).to eq("Ford Taunus")
        expect(item.year).to eq(1980)
        expect(item.price).to eq(10000)
        expect(item.costprice).to eq(500)
        expect(order.orderItems.first).to eq(item)
        expect(item.errors.full_messages).to match_array([])
    end

    it "shouldn't be created if attributes aren't provided" do 
        item = OrderItem.create

        expect(item.errors.full_messages).to match_array(["Order must exist", "Modelname can't be blank", "Year can't be blank", "Year is not a number", "Price can't be blank", "Price is not a number", "Costprice can't be blank", "Costprice is not a number"])
    end

    it "shouldn't be created if year, price and costprice aren't greater than 0 nor if year is older than current year" do
        order = Order.create
        item1 = OrderItem.create(modelName: "Ford Taunus",year: 0,price: 0,costprice: -120,order_id: order.id)
        item2 = OrderItem.create(modelName: "Ford Taunus",year: Time.now.year + 1,price: 10000,costprice: 500,order_id: order.id)
        expect(item1.errors.full_messages).to match_array(["Year must be greater than 0", "Price must be greater than 0", "Costprice must be greater than 0"])
        expect(item2.errors.full_messages).to match_array(["Year must be less than or equal to 2020"])
    end
end

require "rails_helper"

RSpec.describe Order do
    it "should be destroyed regardless or being associated to a stock" do
        stock = Stock.create(name:"Store Stock",type:"StoreStock")
        order = Order.create

        stock.orders << order

        order.destroy

        expect{ order.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it "shouldn't be destroyed if it has items associated to it" do
        order = Order.create
        item = OrderItem.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500,order_id:order.id)
        order.orderItems << item

        expect { order.destroy }.to raise_error ActiveRecord::InvalidForeignKey
    end
end
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

    it "should checkout an order status according to the order condition" do
        maxRetries = (ENV["MAX_RETRIES_ON_PENDING_CARS"] == nil ? 3 : ENV["MAX_RETRIES_ON_PENDING_CARS"].to_i)
        components = JSON.parse((ENV["CAR_COMPONENTS"] == nil ? '{"wheel":4,"chassis":1,"laser":1,"computer":1,"engine":1,"seat":2}' : ENV["CAR_COMPONENTS"]))

        carModel = CarModel.create(car_model_name: "Ford Focus XR",year: 1980,price: 10000,cost_price: 500)
        car1 = Car.new
        car2 = Car.new
        car3 = Car.new
        components.each do | key , value |
            value.to_i.times do
                car1.components << Component.create(name:key,deffective:false)
                car2.components << Component.create(name:key,deffective:false)
                car3.components << Component.create(name:key,deffective:false)
            end
        end
        carModel.cars << car1
        carModel.cars << car2
        carModel.cars << car3
        car1.save
        car2.save
        car3.save

        incompleteOrderWithEN = Order.create
        OrderItem.create(car_model_name: "Ford Focus XR",year: 1980,price: 10000,cost_price: 500,order_id:incompleteOrderWithEN.id,engine_number: car1.id)
        incompleteOrderWithEN = incompleteOrderWithEN.checkout

        incompleteOrderNoEN = Order.create
        OrderItem.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500,order_id:incompleteOrderNoEN.id)
        incompleteOrderNoEN = incompleteOrderNoEN.checkout

        pendingOrderWithEN = Order.create(status: "pending")
        OrderItem.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500,order_id:pendingOrderWithEN.id,engine_number: car2.id)
        pendingOrderWithEN = pendingOrderWithEN.checkout

        pendingOrderNoENNoRetries = Order.create(status: "pending")
        OrderItem.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500,order_id:pendingOrderNoENNoRetries.id)
        pendingOrderNoENNoRetries = pendingOrderNoENNoRetries.checkout

        pendingOrderNoENMaxRetries = Order.create(status: "pending",retries: maxRetries)
        OrderItem.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500,order_id:pendingOrderNoENMaxRetries.id)
        pendingOrderNoENMaxRetries = pendingOrderNoENMaxRetries.checkout

        exchangePendingNoEN = Order.create(status: "exchange pending")
        OrderItem.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500,order_id:exchangePendingNoEN.id)
        exchangePendingNoEN = exchangePendingNoEN.checkout

        exchangePendingWithEN = Order.create(status: "exchange pending")
        OrderItem.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500,order_id:exchangePendingWithEN.id,engine_number: car3.id)
        exchangePendingWithEN = exchangePendingWithEN.checkout

        expect(incompleteOrderWithEN.status).to eq("complete")
        expect(incompleteOrderWithEN.completed_date).to eq(Time.zone.today)

        expect(incompleteOrderNoEN.status).to eq("pending")

        expect(pendingOrderWithEN.status).to eq("complete")
        expect(pendingOrderWithEN.completed_date).to eq(Time.zone.today)

        expect(pendingOrderNoENNoRetries.status).to eq("pending")
        expect(pendingOrderNoENNoRetries.retries).to eq(1)

        expect(pendingOrderNoENMaxRetries.status).to eq("lost sale")
        expect(pendingOrderNoENMaxRetries.completed_date).to eq(Time.zone.today)

        expect(exchangePendingNoEN.status).to eq("lost exchange")
        expect(exchangePendingNoEN.retries).to eq(maxRetries)
        expect(exchangePendingNoEN.completed_date).to eq(Time.zone.today)

        expect(exchangePendingWithEN.status).to eq("complete")
        expect(exchangePendingWithEN.completed_date).to eq(Time.zone.today)
    end
end
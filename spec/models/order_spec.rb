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
        max_retries = (ENV["MAX_RETRIES_ON_PENDING_CARS"] == nil ? 3 : ENV["MAX_RETRIES_ON_PENDING_CARS"].to_i)
        components = JSON.parse((ENV["CAR_COMPONENTS"] == nil ? '{"wheel":4,"chassis":1,"laser":1,"computer":1,"engine":1,"seat":2}' : ENV["CAR_COMPONENTS"]))

        car_model = CarModel.create(car_model_name: "Ford Focus XR",year: 1980,price: 10000,cost_price: 500)
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
        car_model.cars << car1
        car_model.cars << car2
        car_model.cars << car3
        car1.save
        car2.save
        car3.save

        incomplete_order_with_en = Order.create
        OrderItem.create(car_model_name: "Ford Focus XR",year: 1980,price: 10000,cost_price: 500,order_id:incomplete_order_with_en.id,engine_number: car1.id)
        incomplete_order_with_en = incomplete_order_with_en.checkout

        incomplete_order_no_en = Order.create
        OrderItem.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500,order_id:incomplete_order_no_en.id)
        incomplete_order_no_en = incomplete_order_no_en.checkout

        pending_order_with_en = Order.create(status: "pending")
        OrderItem.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500,order_id:pending_order_with_en.id,engine_number: car2.id)
        pending_order_with_en = pending_order_with_en.checkout

        pending_order_no_en_no_retries = Order.create(status: "pending")
        OrderItem.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500,order_id:pending_order_no_en_no_retries.id)
        pending_order_no_en_no_retries = pending_order_no_en_no_retries.checkout

        pending_order_no_en_max_retries = Order.create(status: "pending",retries: max_retries)
        OrderItem.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500,order_id:pending_order_no_en_max_retries.id)
        pending_order_no_en_max_retries = pending_order_no_en_max_retries.checkout

        exchange_pending_no_en = Order.create(status: "exchange pending")
        OrderItem.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500,order_id:exchange_pending_no_en.id)
        exchange_pending_no_en = exchange_pending_no_en.checkout

        exchange_pending_with_en = Order.create(status: "exchange pending")
        OrderItem.create(car_model_name: "Ford Taunus",year: 1980,price: 10000,cost_price: 500,order_id:exchange_pending_with_en.id,engine_number: car3.id)
        exchange_pending_with_en = exchange_pending_with_en.checkout

        expect(incomplete_order_with_en.get_status).to eq(:complete)
        expect(incomplete_order_with_en.completed_date).to eq(Time.zone.today)

        expect(incomplete_order_no_en.get_status).to eq(:pending)

        expect(pending_order_with_en.get_status).to eq(:complete)
        expect(pending_order_with_en.completed_date).to eq(Time.zone.today)

        expect(pending_order_no_en_no_retries.get_status).to eq(:pending)
        expect(pending_order_no_en_no_retries.retries).to eq(1)

        expect(pending_order_no_en_max_retries.get_status).to eq(:lost_sale)
        expect(pending_order_no_en_max_retries.completed_date).to eq(Time.zone.today)

        expect(exchange_pending_no_en.get_status).to eq(:lost_exchange)
        expect(exchange_pending_no_en.retries).to eq(max_retries)
        expect(exchange_pending_no_en.completed_date).to eq(Time.zone.today)

        expect(exchange_pending_with_en.get_status).to eq(:complete)
        expect(exchange_pending_with_en.completed_date).to eq(Time.zone.today)
    end
end
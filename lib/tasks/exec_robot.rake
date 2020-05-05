namespace :exec_robot do
    desc "Exec Robot tasks"
    
    task generate_business_statistics: [:environment] do
        orders = Array.new(Order.all)

        completed_orders = Array.new
        
        daily_revenue = 0
        daily_cost = 0
        cars_sold = 0
        yesterday_lost_sales = 0
        yesterday_revenue_lost = 0
        total_prices = 0
        total_cars = 0
        pending_revenue = 0
        pending_cars = 0
        in_guarantee = 0
        average_order = 0
        
        #Based on orders completed the previous day OR created the previous day and still pending, I will need to determine
        #some variables to be able to perform calculations that will be shown in the output.
        orders.each do | order |
            if(order.in_guarantee)
                in_guarantee += 1
            end

            if(order.completed_date == Time.zone.yesterday || (order.status == "pending" && order.created_at.to_date == Time.zone.yesterday))
                order.orderItems.each do | item |
                    total_prices += (item.price - item.cost_price)
                    total_cars += 1
                    if(item.engine_number != nil)
                        cars_sold += 1
                        daily_revenue += (item.price - item.cost_price)
                        daily_cost += item.cost_price
                    elsif
                        if(item.order.status != "pending")
                            yesterday_lost_sales += 1
                            yesterday_revenue_lost += (item.price - item.cost_price)
                        else
                            pending_revenue += (item.price - item.cost_price)
                            pending_cars += 1
                        end
                    end
                end
            end
        end
        
        unless(cars_sold == 0)
            average_order = (total_prices / total_cars)
        end

        puts "Business Statistics from #{Time.zone.yesterday}"
        puts "Daily revenue: $#{daily_revenue}"
        puts "Daily cost: $#{daily_cost}"
        puts "Cars sold: #{cars_sold} units"
        puts "Average order price: $#{average_order}"
        puts "Amount of orders still in guarantee: #{in_guarantee}"
        puts "Pending revenue the robot buyer is still able to retry (in money): $#{pending_revenue}"
        puts "Units in order that the robot buyer is still able to retry: #{pending_cars}"
        puts "Yesterday Lost sales due to stock unavailabilty or exchanged orders that couldn't be sufficed (in car units): #{yesterday_lost_sales} units"
        puts "Yesterday Lost sales due to stock unavailabilty or exchanged orders that couldn't be sufficed (in money): $#{yesterday_revenue_lost}"
    end
end
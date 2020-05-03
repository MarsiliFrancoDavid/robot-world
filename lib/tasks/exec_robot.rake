namespace :exec_robot do
    desc "Exec Robot tasks"
    
    task generate_business_statistics: [:environment] do
        loop do
            sleep(1.day)
            orders = Array.new(Order.all)

            completedOrders = Array.new
            
            dailyRevenue = 0
            dailyCost = 0
            carsSold = 0
            yesterdayLostSales = 0
            yesterdayRevenueLost = 0
            totalPrices = 0
            totalCars = 0
            pendingRevenue = 0
            pendingCars = 0
            inGuarantee = 0
            
            #Based on orders completed the previous day OR created the previous day and still pending, I will need to determine
            #some variables to be able to perform calculations that will be shown in the output.
            orders.each do | order |
                if(order.inGuarantee)
                    inGuarantee += 1
                end

                if(order.completedDate == Time.zone.yesterday || (order.status == "pending" && order.created_at.to_date == Time.zone.yesterday))
                    order.orderItems.each do | item |
                        totalPrices += (item.price - item.costprice)
                        totalCars += 1
                        if(item.engineNumber != nil)
                            carsSold += 1
                            dailyRevenue += (item.price - item.costprice)
                            dailyCost += item.costprice
                        elsif
                            if(item.order.status != "pending")
                                yesterdayLostSales += 1
                                yesterdayRevenueLost += (item.price - item.costprice)
                            else
                                pendingRevenue += (item.price - item.costprice)
                                pendingCars += 1
                            end
                        end
                    end
                end
            end
            
            unless(carsSold == 0)
                averageOrder = (totalPrices / totalCars)
            end

            puts "Business Statistics from #{Time.zone.yesterday}"
            puts "Daily revenue: $#{dailyRevenue}"
            puts "Daily cost: $#{dailyCost}"
            puts "Cars sold: #{carsSold} units"
            puts "Average order price: $#{averageOrder}"
            puts "Amount of orders still in guarantee: #{inGuarantee}"
            puts "Pending revenue the robot buyer is still able to retry (in money): $#{pendingRevenue}"
            puts "Units in order that the robot buyer is still able to retry: #{pendingCars}"
            puts "Yesterday Lost sales due to stock unavailabilty or exchanged orders that couldn't be sufficed (in car units): #{yesterdayLostSales} units"
            puts "Yesterday Lost sales due to stock unavailabilty or exchanged orders that couldn't be sufficed (in money): $#{yesterdayRevenueLost}"
        end
    end
end
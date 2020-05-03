class Stock < ApplicationRecord
    has_many :cars
    has_many :orders
    validates :name , :type , presence: true

    #send an array of car objects and it will be saved associated to the stock
    def addCars(cars)
        cars.each do | car |
            self.cars << car
        end
        begin
            if(!self.save)
                puts "An error has ocurred saving the cars in the #{self.name}"
                puts self.errors.full_messages
            end
        rescue StandardError => e
            print e
        end
    end

    #deletes the association of each car to this stock and return all of them as an array
    def withdrawCars
        carsCopy = Array.new

        self.cars.each do | car | 
            self.cars.delete(car)
            carsCopy << car
        end

        begin
            if(!self.save)
                puts "An error has ocurred withdrawing cars in the #{self.name}"
                puts self.errors.full_messages
            end
        rescue StandardError => e
            print e
        end
        carsCopy
    end

    def consultCarsStockByModelName(modelName , year)
        result = 0

        self.cars.each do | car |
            if(car.car_model.modelName == modelName && car.car_model.year == year)
                result += 1
            end
        end

        result
    end
end

class Stock < ApplicationRecord
    has_many :cars
    has_many :orders
    validates :name , :type , presence: true

    #send an array of car objects and it will be saved associated to the stock
    def add_cars(cars)
        cars.each do | car |
            self.cars << car
        end

        begin
            if(!self.save)
                puts "An error has ocurred saving the cars in the #{self.name}"
                puts self.errors.full_messages
            end
        rescue StandardError => e
            Rails.logger.error e
        end
    end

    #deletes the association of each car to this stock and return all of them as an array
    def withdraw_cars
        cars_copy = Array.new(self.cars)
        self.cars.delete_all

        begin
            if(!self.save)
                puts "An error has ocurred withdrawing cars in the #{self.name}"
                puts self.errors.full_messages
            end
        rescue StandardError => e
            Rails.logger.error e
        end
        cars_copy
    end

    def consult_cars_stock_by_model_name(car_model_name , year)
        result = (self.cars.joins(:car_model).where('car_models.car_model_name' => car_model_name , 'car_models.year' => year)).length
    end
end

require_relative "car"
require_relative "application_record"

#This class is for pretending purposes only. It simulates
#the transition of the cars through each step until it"s
#considered finished.
class CarFactory
    attr_accessor :assembly_lines,:completed_cars
    
    #Each Car is identified by it"s ID as a hash key inside each production line
    def initialize()
        @assembly_lines = { 
            "Basic Structure"            => {},
            "Electronic devices"         => {},
            "Painting and final details" => {}
        }
        @completed_cars = []
    end
   
    def start_production(car)
        verbose_prod = (ENV["COMMENTED_PRODUCTION"] == nil ? "false" : ENV["COMMENTED_PRODUCTION"].downcase)
        commented_production = verbose_prod == "true"
        while(!car.completed)
            if(commented_production)
                puts "Moving car with engine number #{car.id.to_s} from #{car.stage} to the next stage"
            end
            car = send_to_next_line(car)
        end
    end

    def send_to_next_line(car)
        previous_stage = car.stage

        if(previous_stage.downcase == "uninitialized")
            car.stage = "Basic Structure"
        elsif (previous_stage.downcase == "basic structure")
            car.stage = "Electronic devices"
        elsif (previous_stage.downcase == "electronic devices")
            car.stage = "Painting and final details"
        elsif (previous_stage.downcase == "painting and final details")
            car.stage = "completed"
            car.completed = true
        end

        unless(previous_stage.downcase === "uninitialized")
            @assembly_lines[previous_stage].delete(car.id.to_s)
        end

        if(car.completed)
            car.components.each do | component |
                if(component.deffective)
                    car.deffects << component.name
                end
            end
            @completed_cars << car
        else
            @assembly_lines[car.stage][car.id.to_s] = car
        end
        return car
    end

    def withdraw_completed_cars
        completed_cars_copy = Array.new(@completed_cars)
        @completed_cars.clear
        completed_cars_copy
    end


end
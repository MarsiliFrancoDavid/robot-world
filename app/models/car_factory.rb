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
            :basic_structure            => {},
            :electronic_devices         => {},
            :painting_and_final_details => {}
        }
        @completed_cars = []
    end
   
    def start_production(car)
        verbose_prod = ENV["COMMENTED_PRODUCTION"] || "false"
        commented_production = verbose_prod == "true"
        while(!car.completed)
            if(commented_production)
                puts "Moving car with engine number #{car.id.to_s} from #{car.stage} to the next stage"
            end
            car = send_to_next_line(car)
        end
    end

    def send_to_next_line(car)
        previous_stage = car.get_stage

        case previous_stage

        when :uninitialized
            car.stage = :basic_structure
        when :basic_structure
            car.stage = :electronic_devices
        when :electronic_devices
            car.stage = :painting_and_final_details
        when :painting_and_final_details
            car.stage = :completed
            car.completed = true
        else
            puts "Car Factory was unable to handle the stage of car with id #{car.id}"
        end

        unless(previous_stage === :uninitialized)
            @assembly_lines[previous_stage].delete(car.id.to_s)
        end

        if(car.completed)
            car.components.deffectives.each do | component |
                car.deffects << component.name
            end
            @completed_cars << car
        else
            @assembly_lines[car.get_stage][car.id.to_s] = car
        end
        return car
    end

    def withdraw_completed_cars
        completed_cars_copy = Array.new(@completed_cars)
        @completed_cars.clear
        completed_cars_copy
    end


end
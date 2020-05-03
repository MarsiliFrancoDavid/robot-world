require_relative "car"
require_relative "application_record"

#This class is for pretending purposes only. It simulates
#the transition of the cars through each step until it"s
#considered finished.
class CarFactory
    attr_accessor :assemblyLines,:completedCars
    
    #Each Car is identified by it"s ID as a hash key inside each production line
    def initialize()
        @assemblyLines = { 
            "Basic Structure"            => {},
            "Electronic devices"         => {},
            "Painting and final details" => {}
        }
        @completedCars = []
    end
   
    def startProduction(car)
        verboseProd = (ENV["pg_commented_production"] == nil ? "false" : ENV["pg_commented_production"].downcase)
        commentedProduction = verboseProd == "true"
        while(!car.completed)
            if(commentedProduction)
                puts "Moving car with engine number #{car.id.to_s} from #{car.stage} to the next stage"
            end
            car = sendToNextLine(car)
        end
    end

    def sendToNextLine(car)
        previousStage = car.stage

        if(previousStage.downcase == "uninitialized")
            car.stage = "Basic Structure"
        elsif (previousStage.downcase == "basic structure")
            car.stage = "Electronic devices"
        elsif (previousStage.downcase == "electronic devices")
            car.stage = "Painting and final details"
        elsif (previousStage.downcase == "painting and final details")
            car.stage = "completed"
            car.completed = true
        end

        unless(previousStage.downcase === "uninitialized")
            @assemblyLines[previousStage].delete(car.id.to_s)
        end

        if(car.completed)
            car.components.each do | component |
                if(component.deffective)
                    car.deffects << component.name
                end
            end
            @completedCars << car
        else
            @assemblyLines[car.stage][car.id.to_s] = car
        end
        return car
    end

    def withdrawCompletedCars
        completedCarsCopy = Array.new(@completedCars)
        @completedCars.clear
        completedCarsCopy
    end


end
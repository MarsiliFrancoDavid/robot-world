require_relative "stock"
require_relative "car"
require_relative "component"


class DeffectiveStock < Stock
    #This method takes the cars with at least one deffective component, loops into them and disassociates the component
    #from the car if it isn't deffective or destroys it if it is. Then it destroys the car.
    def turn_deffective_cars_into_components
        components_returned = 0
        self.cars.each do | car |
            begin
                components_returned += car.components.not_deffectives.delete_all
                car.components.deffectives.destroy_all
            rescue StandardError => e
                print e
            end

            self.cars.delete(car)
            
            begin
                car.destroy
            rescue StandardError => e
                print e
            end
        end
        
        begin
            if(!self.save)
                puts "There was an error trying to save the Deffective Stock one the deffective cars were destroyed"
                puts self.errors.full_messages
            end
        rescue StandardError => e
            print e
        end
        
        components_returned
    end
    
end

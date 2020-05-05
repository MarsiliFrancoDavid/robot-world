class Order < ApplicationRecord
	belongs_to :stock, class_name: "Stock", optional: true
	has_many :orderItems
	validates :status, :retries, presence: true
	scope :completed_before_yesterday, -> { where('completed_date < ?',Time.zone.today) }
	scope :with_status, -> (status) { where('status = ?',status.to_s) }
	scope :with_retries_not_maxed_out, -> (max_retries) { where('retries < ?',max_retries) }
	scope :still_in_guarantee, -> { where('in_guarantee = ?',true) }

	def get_status
        self.status.parameterize.underscore.to_sym
    end

	#evaluates if the order is completed based on if its items have an engine_number attribute defined, if not it means
	#that there was no stock for the operation, wether it be first transaction, a pending transaction or an exchange
  	def checkout
      	max_retries = (ENV["MAX_RETRIES_ON_PENDING_CARS"] == nil ? 3 : ENV["MAX_RETRIES_ON_PENDING_CARS"].to_i)
		lost = false
		completed = true  

		self.orderItems.each do | item |
			#also check for the car to still exist at the moment of the checkout, because maybe it could be
			#deleted due to the cleanup daily task.
			carItem = Car.find_by(id: item.engine_number)

			if(carItem == nil)
          		completed = false
        	end
      	end

		#based on the fact of being complete or not, set the status in the order and the output for the user and the time
		#for when it was completed if it was.
      	if(completed)
			self.status = :complete
			puts "Order with purchaseID : #{self.id} succesfully completed"
      	else
			if(self.get_status == :pending)
				self.retries += 1

				if(self.retries >= max_retries)
					self.status = :lost_sale
					lost = true
					puts "Order with purchaseID: #{self.id} was retried maximum amount of times and is now declared as lost"
				else
					puts "Order with purchaseID: #{self.id} wasn't sufficed and will return to the pending queue"
				end
        	elsif(self.get_status == :exchange_pending)
				self.status = :lost_exchange
				self.retries = max_retries
				lost = true
				puts "Order with purchaseID: #{self.id} wasn't succesfuly exchanged and is now declared as a lost sale"
			elsif(self.get_status == :incomplete)
				puts "Order with purchaseID : #{self.id} wasn't completed and it's now pending"
            	self.status = :pending
        	end
      	end

      	if(completed || lost)
        	self.completed_date = Time.zone.today
      	end

      	begin
        	if(!self.save)
          		puts "An error ocurred trying to save the order in the checkout process"
        	end
      	rescue StandardError => e
        	Rails.logger.error e
		end
		  
		#return the modified order for the stock to know if it has to store it as a complete / lost sale / lost exchange order.
		return self
  	end
end

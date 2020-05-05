class Car < ApplicationRecord
  has_many :components
  belongs_to :stock, class_name: 'Stock', optional: true
  belongs_to :car_model
  validates :stage, presence: true
  validate :all_components_loaded, :on => :create

  def all_components_loaded
      components = JSON.parse(ENV["CAR_COMPONENTS"])
      valid = true

      unless(components == {})
          car_components = Array.new(self.components)

          car_components.each do | component |
              components[component.name] -= 1
          end
      end

      components.each do | key , value |
          if(value != 0)
              valid = false
          end
      end

      if(!valid)
          errors.add(:components,"must be present")
      end

      valid
  end
end

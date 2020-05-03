class Car < ApplicationRecord
  has_many :components
  belongs_to :stock, class_name: 'Stock', optional: true
  belongs_to :car_model
  validates :stage, presence: true
  validate :all_components_loaded, :on => :create

  def all_components_loaded
      components = JSON.parse(ENV["pg_car_components"])
      valid = true

      unless(components == {})
          carComponents = Array.new(self.components)

          carComponents.each do | component |
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

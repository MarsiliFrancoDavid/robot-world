class Car < ApplicationRecord
    has_many :components
    belongs_to :stock, class_name: 'Stock', optional: true
    belongs_to :car_model
    validates :stage, presence: true
    scope :with_model_name, -> (searched_car_model_name) { joins(:car_model).where(car_models: {car_model_name: searched_car_model_name} ) }
    scope :with_model_year, -> (year_model) { joins(:car_model).where(car_models: {year: year_model} ) }

    def get_stage
        self.stage.parameterize.underscore.to_sym
    end

    def is_deffective?
        return (self.deffects.length > 0)
    end
end

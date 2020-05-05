class Car < ApplicationRecord
    has_many :components
    belongs_to :stock, class_name: 'Stock', optional: true
    belongs_to :car_model
    validates :stage, presence: true

    def get_stage
        self.stage.parameterize.underscore.to_sym
    end

    def is_deffective?
        return (self.deffects.length > 0)
    end
end

class Component < ApplicationRecord
  belongs_to :car, class_name: "Car", optional: true
  validates :name, presence: true
end

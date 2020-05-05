class Component < ApplicationRecord
  belongs_to :car, class_name: "Car", optional: true
  validates :name, presence: true
  scope :deffectives, -> { where("is_deffective = ?",true) }
  scope :not_deffectives, -> { where("is_deffective = ?",false) }
end

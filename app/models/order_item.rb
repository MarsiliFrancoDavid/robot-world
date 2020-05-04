class OrderItem < ApplicationRecord
  belongs_to :order
  validates :model_name, :year, :price, :cost_price, presence: true
  validates :year, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: Time.current.year }
  validates :price, numericality: { only_integer: true, greater_than: 0 }
  validates :cost_price, numericality: { only_integer: true, greater_than: 0 }
end

class Order < ApplicationRecord
  belongs_to :stock, class_name: "Stock", optional: true
  has_many :orderItems
  validates :status, :retries, :in_guarantee, presence: true
end

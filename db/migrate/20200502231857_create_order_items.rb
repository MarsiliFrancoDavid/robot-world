class CreateOrderItems < ActiveRecord::Migration[6.0]
  def change
    create_table :order_items do |t|
      t.string :modelName
      t.integer :year
      t.integer :price
      t.integer :costprice
      t.integer :engineNumber
      t.references :order, index: true, foreign_key: true

      t.timestamps
    end
  end
end

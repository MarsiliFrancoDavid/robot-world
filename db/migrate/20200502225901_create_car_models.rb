class CreateCarModels < ActiveRecord::Migration[6.0]
  def change
    create_table :car_models do |t|
      t.string :modelName
      t.integer :year
      t.integer :price
      t.integer :costprice

      t.timestamps
    end
  end
end

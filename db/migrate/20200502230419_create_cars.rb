class CreateCars < ActiveRecord::Migration[6.0]
  def change
    create_table :cars do |t|
      t.text :deffects, default: [], array: true
      t.string :stage, default: "Uninitialized"
      t.boolean :completed, default: false
      t.references :stock, index: true , foreign_key: true
      t.references :car_model, index: true, foreign_key: true

      t.timestamps
    end
  end
end

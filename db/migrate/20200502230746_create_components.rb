class CreateComponents < ActiveRecord::Migration[6.0]
  def change
    create_table :components do |t|
      t.string :name
      t.boolean :deffective
      t.references :car, index: true, foreign_key: true

      t.timestamps
    end
  end
end

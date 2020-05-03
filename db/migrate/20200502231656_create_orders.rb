class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.string :status, default: "incomplete"
      t.references :stock, index: true, foreign_key: true
      t.integer :retries, default: 0
      t.date :completedDate
      t.boolean :inGuarantee, default: true

      t.timestamps
    end
  end
end

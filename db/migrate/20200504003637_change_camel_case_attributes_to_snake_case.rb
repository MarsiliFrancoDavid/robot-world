class ChangeCamelCaseAttributesToSnakeCase < ActiveRecord::Migration[6.0]
  def change
    rename_column :car_models, :modelName, :model_name
    rename_column :car_models, :costprice, :cost_price
    rename_column :order_items, :modelName, :model_name
    rename_column :order_items, :costprice, :cost_price
    rename_column :order_items, :engineNumber, :engine_number
    rename_column :orders, :completedDate, :completed_date
    rename_column :orders, :inGuarantee, :in_guarantee
  end
end

class ChangeModelNameToModelModelName < ActiveRecord::Migration[6.0]
  def change
    rename_column :car_models, :model_name, :car_model_name
    rename_column :order_items, :model_name, :car_model_name
  end
end

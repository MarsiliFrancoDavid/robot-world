class ChangeComponentColumnNameFromDeffectiveToIsDeffective < ActiveRecord::Migration[6.0]
  def change
    rename_column :components, :deffective, :is_deffective
  end
end

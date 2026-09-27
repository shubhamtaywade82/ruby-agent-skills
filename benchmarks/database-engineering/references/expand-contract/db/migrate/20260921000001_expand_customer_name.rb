class ExpandCustomerName < ActiveRecord::Migration[8.1]
  def change
    add_column :customers, :display_name, :string
  end
end

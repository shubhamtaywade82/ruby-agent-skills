class AddOrdersStatusIndex < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :orders, :status, algorithm: :concurrently
  end
end

class AddOrderReferenceConstraint < ActiveRecord::Migration[8.1]
  def change
    add_index :orders, [:tenant_id, :external_reference], unique: true
  end
end

class Order < ApplicationRecord
  validates :external_reference, uniqueness: { scope: :tenant_id }
end

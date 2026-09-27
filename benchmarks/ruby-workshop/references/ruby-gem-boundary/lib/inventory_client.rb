# Public entry point: `require "inventory_client"` loads the whole API.
module InventoryClient
  VERSION = "0.1.0"

  class NotFound < StandardError; end

  # The catalog is injected so the gem carries no application dependency.
  def self.fetch(product_id, catalog:)
    catalog.fetch(product_id) { raise NotFound, "unknown product: #{product_id}" }
  end
end

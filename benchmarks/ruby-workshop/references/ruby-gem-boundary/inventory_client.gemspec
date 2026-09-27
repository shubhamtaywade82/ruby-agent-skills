require_relative "lib/inventory_client"

Gem::Specification.new do |spec|
  spec.name = "inventory_client"
  spec.version = InventoryClient::VERSION
  spec.authors = ["Ruby Agent Skills"]
  spec.summary = "Inventory client"
  spec.description = "A small, dependency-free client boundary for inventory lookups."
  spec.license = "MIT"
  spec.homepage = "https://example.invalid/inventory_client"
  spec.required_ruby_version = ">= 3.2"
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.files = Dir["lib/**/*"]
  spec.require_paths = ["lib"]
end

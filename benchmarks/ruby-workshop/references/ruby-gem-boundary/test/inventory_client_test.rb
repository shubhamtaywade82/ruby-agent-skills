require "minitest/autorun"
$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "inventory_client"

class InventoryClientTest < Minitest::Test
  def test_public_require_path_exposes_version
    assert_equal "0.1.0", InventoryClient::VERSION
  end

  def test_fetch_returns_catalog_entry
    assert_equal({ sku: "A1" }, InventoryClient.fetch("A1", catalog: { "A1" => { sku: "A1" } }))
  end

  def test_unknown_product_raises
    assert_raises(InventoryClient::NotFound) { InventoryClient.fetch("Z9", catalog: {}) }
  end

  def test_gemspec_packages_library_files
    spec = Gem::Specification.load(File.expand_path("../inventory_client.gemspec", __dir__))
    assert_includes spec.files, "lib/inventory_client.rb"
  end
end

class Catalog
  def available_names(products)
    products.select { |product| product[:available] == true }.map { |product| product[:name] }
  end
end

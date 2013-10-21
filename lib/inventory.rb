class Inventory
  attr_accessor :seller_sku, :total_supply_quantity, :in_stock_supply_quantity

  def initialize(inventory_hash)
    @seller_sku               = inventory_hash[:seller_sku]
    @total_supply_quantity    = inventory_hash[:total_supply_quantity]
    @in_stock_supply_quantity = inventory_hash[:in_stock_supply_quantity]
  end

  def to_message
    { message: 'stock:actual',
      payload: {
      sku: @seller_sku,
      quantity: @in_stock_supply_quantity } }
  end
end


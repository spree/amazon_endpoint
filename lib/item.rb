class Item

  def initialize(item_hash)
    @name = item_hash.title
    @price = item_hash.item_price.amount
    @sku = item_hash.seller_sku
    @quantity = item_hash.quantity_ordered
  end
end
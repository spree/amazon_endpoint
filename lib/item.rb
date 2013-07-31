class Item
  attr_accessor :shipping_price, :item_price, :item_tax, :promotion_discount,
                :shipping_discount, :gift_wrap, :gift_wrap_tax, :price

  def initialize(item_hash)
    @name = item_hash['title']
    @price = item_hash['item_price']['amount'].to_f
    @sku = item_hash['seller_sku']
    @quantity = item_hash['quantity_ordered'].to_i
    @quantity_shipped = item_hash['quantity_shipped']
    @item_price = item_hash['item_price']['amount'].to_f
    @shipping_price = item_hash['shipping_price']['amount'].to_f
    @item_tax = item_hash['item_tax']['amount'].to_f
    @promotion_discount = item_hash['promotion_discount']['amount'].to_f
    @shipping_discount = item_hash['shipping_discount']['amount'].to_f
    @gift_wrap = item_hash['gift_wrap_price']['amount'].to_f
    @gift_wrap_tax = item_hash['gift_wrap_tax']['amount'].to_f
  end

  def to_h
    { name: @name, price: @price, sku: @sku, quantity: @quantity, variant_id: '', external_ref: '',
      options: {} }
  end
end
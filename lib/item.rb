#ATTRIBUTES FOR MWS ITEM

# "order_item_id": "",
# "gift_wrap_price": {
#   "amount": "0.00",
#   "currency_code": "USD"
# },
# "quantity_ordered": "1",
# "gift_wrap_tax": {
#   "amount": "0.00",
#   "currency_code": "USD"
# },
# "seller_sku": "",
# "title": "",
# "shipping_tax": {
#   "amount": "0.00",
#   "currency_code": "USD"
# },
# "shipping_price": {
#   "amount": "0.00",
#   "currency_code": "USD"
# },
# "item_tax": {
#   "amount": "0.00",
#   "currency_code": "USD"
# },
# "item_price": {
#   "amount": "40.00",
#   "currency_code": "USD"
# },
# "promotion_discount": {
#   "amount": "0.00",
#   "currency_code": "USD"
# },
# "asin": "",
# "condition_id": "New",
# "quantity_shipped": "1",
# "condition_subtype_id": "New",
# "shipping_discount": {
#   "amount": "0.00",
#   "currency_code": "USD"
# }

# ITEM MESSAGE
#    { name: item.title,
#      price: item.item_price.amount,
#      sku: item.seller_sku,
#      quantity: item.quantity_ordered }

class Item
  attr_accessor :shipping_price, :item_price, :item_tax, :promotion_discount,
                :shipping_discount, :gift_wrap, :gift_wrap_tax, :price

  def initialize(item_hash)
    @name = item_hash['title']
    @price = item_hash['item_price']['amount'].to_f
    @sku = item_hash['seller_sku']
    @quantity = item_hash['quantity_ordered']
    @item_price = item_hash['item_price']['amount'].to_f
    @shipping_price = item_hash['shipping_price']['amount'].to_f
    @item_tax = item_hash['item_tax']['amount'].to_f
    @promotion_discount = item_hash['promotion_discount']['amount'].to_f
    @shipping_discount = item_hash['shipping_discount']['amount'].to_f
    @gift_wrap = item_hash['gift_wrap_price']['amount'].to_f
    @gift_wrap_tax = item_hash['gift_wrap_tax']['amount'].to_f
  end

  def to_h
    { name: @name, price: @price, sku: @sku, quanitity: @quantity }
  end
end
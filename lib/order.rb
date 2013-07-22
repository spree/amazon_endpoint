class Order
  attr_accessor :line_items,

  def initialize(order_hash)
    @line_items = []
    @amazon_order_id = order_hash.amazon_order_id
    @channel = order_hash.sales_channel
    @currency = order_hash.order_total.currency_code
    @status = order_hash.order_status
    @placed_on = order_hash.purchase_date
    @updated_at = order_hash.last_update_date
    @email = order_hash.buyer_email
    @shipping_address = build_address_hash(order),
    @shipping_method = order_hash.shipment_service_level_category
  end
end
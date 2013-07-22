# ATTRIBUTES FOR AN MWS ORDER
#   "amazon_order_id",
#   "shipment_service_level_category": "Standard",
#   "order_total": {
#     "amount": "40.00",
#     "currency_code": "USD"
#   },
#   "ship_service_level": "Std Cont US Street Addr",
#   "marketplace_id": "",
#   "shipping_address": {
#     "phone": "",
#     "postal_code": "",
#     "name": "",
#     "country_code": "US",
#     "state_or_region": "",
#     "address_line1": "",
#     "city": ""
#   },
#   "sales_channel": "Amazon.com",
#   "shipped_by_amazon_tfm": "false",
#   "order_type": "StandardOrder",
#   "buyer_email": "",
#   "fulfillment_channel": "MFN",
#   "order_status": "Shipped",
#   "buyer_name": "",
#   "last_update_date": "2013-07-10T13:46:39Z",
#   "purchase_date": "2013-07-08T16:33:34Z",
#   "number_of_items_unshipped": "0",
#   "number_of_items_shipped": "1",
#   "amazon_order_id": "104-0323693-7114632",
#   "payment_method": "Other"

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
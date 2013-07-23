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

# FORMAT FOR ORDER RESPONSE
# { order:
#   { amazon_order_id: @attr_hash.amazon_order_id,
#     channel: @attr_hash.sales_channel,
#     currency: @attr_hash.order_total.currency_code,
#     status: @attr_hash.order_status,
#     placed_on: @attr_hash.purchase_date,
#     updated_at: @attr_hash.last_update_date,
#     email: @attr_hash.buyer_email,
#     line_items: [],
#     shipping_address: build_address_hash(order),
#     shipments: {
#       shipping_method: @attr_hash.shipment_service_level_category,
#       items: []
# firstname: @attr_hash.buyer_name.split(' ').first,
#       lastname: @attr_hash.buyer_name.split(' ').last,
#       address1: @attr_hash.shipping_address.address_line1,
#       city: @attr_hash.shipping_address.city,
#       zipcode: @attr_hash.shipping_address.postal_code,
#       phone: @attr_hash.shipping_address.phone,
#       country: @attr_hash.shipping_address.country_code,
#       state: @attr_hash.shipping_address.state_or_region

class Order
  attr_accessor :line_items

  def initialize(attr_hash)
    @line_items = []
    @attr_hash = attr_hash
  end

  def to_message
    items_hash = assemble_line_items
    address_hash = assemble_address
    shipments_hash = assemble_shipments

    { message: 'order:new',
      payload:
      { order:
        { amazon_order_id: @attr_hash['amazon_order_id'],
          channel: @attr_hash['sales_channel'],
          currency: @attr_hash['order_total']['currency_code'],
          status: @attr_hash['order_status'],
          placed_on: @attr_hash['purchase_date'],
          updated_at: @attr_hash['last_update_date'],
          email: @attr_hash['buyer_email'],
          line_items: items_hash,
          shipping_address: address_hash,
          billing_address: address_hash }}}
  end

  def assemble_line_items
    @line_items.collect { |item| item.to_h }
  end

  def assemble_address
    { firstname: @attr_hash['buyer_name'].split(' ').first,
      lastname: @attr_hash['buyer_name'].split(' ').last,
      address1: @attr_hash['shipping_address']['address_line1'],
      city: @attr_hash['shipping_address']['city'],
      zipcode: @attr_hash['shipping_address']['postal_code'],
      phone: @attr_hash['shipping_address']['phone'],
      country: @attr_hash['shipping_address']['country_code'],
      state: @attr_hash['shipping_address']['state_or_region'] }
  end
end
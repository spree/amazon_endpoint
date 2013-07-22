class AmazonClient

  def initialize(config, message)
    @client = MWS.new(aws_access_key_id: config['amazon.aws_access_key'],
                      secret_access_key: config['amazon.secret_key'],
                      seller_id:         config['amazon.seller_id'],
                      marketplace_id:    config['amazon.marketplace_id'])
    @last_updated = config['amazon.last_updated_after']
    @config = config
  end

  def get_orders
    statuses = ['Unshipped', 'PartiallyShipped', 'Shipped']
    order_list = @client.orders.list_orders(last_updated_after: @last_updated, order_status: statuses)

    if order_list.orders.nil?
      nil
    elsif order_list.orders.is_a? MWS::API::Response
      assemble_response([order_list.orders])
    else
      assemble_response(order_list.orders)
    end
  end

  private
  def assemble_response(order_list)
    messages_hash = { messages: [] }
    last_updated_at = order_list.last.last_update_date

    order_list.each_with_index do |order, index|
      shipping_total = 0
      messages_hash[:messages] << build_order_hash(order)

      item_response = @client.orders.list_order_items(amazon_order_id: order.amazon_order_id)

      item_response.order_items.each do |item|
        shipping_total = shipping_total + item.shipping_price.amount.to_f
        item_hash = build_item_hash(item)

        messages_hash[:messages][index][:payload][:order][:line_items] << item_hash
        messages_hash[:messages][index][:payload][:order][:shipments][:items] << item_hash
      end
      messages_hash[:messages][index][:payload][:order][:shipments][:cost] = shipping_total
    end

    messages_hash[:parameters] = [{ name: 'last_updated_after', value: last_updated_at }]
    messages_hash
  end

  def build_order_hash(order)
    { message: 'order:new',
      payload:
        { order:
          { amazon_order_id: order.amazon_order_id,
            channel: order.sales_channel,
            status: order.order_status,
            email: order.buyer_email,
            line_items: [],
            shipping_address: address_hash(order),
            shipments: {
              shipping_method: order.shipment_service_level_category,
              items: [] }}}}
  end

  def build_item_hash(item)
    { name: item.title,
      price: item.item_price.amount,
      sku: item.seller_sku,
      quantity: item.quantity_shipped }
  end

  def address_hash(order)
    { firstname: order.buyer_name.split(' ').first,
      lastname: order.buyer_name.split(' ').last,
      address1: order.shipping_address.address_line1,
      city: order.shipping_address.city,
      zipcode: order.shipping_address.postal_code,
      phone: order.shipping_address.phone,
      country: order.shipping_address.country_code,
      state: order.shipping_address.state_or_region }
  end
end
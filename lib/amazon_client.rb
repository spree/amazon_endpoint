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
    statuses = %w(Unshipped PartiallyShipped)
    order_list = @client.orders.list_orders(last_updated_after: @last_updated, order_status: statuses)

    filtered_orders_hash = remove_partially_shipped(order_list.orders)

    get_line_items filtered_orders_hash
  end

  private
  def remove_partially_shipped(orders)
    orders = [orders] if orders.is_a? MWS::API::Response
    orders.to_a.
      reject { |order_hash|  order_hash['order_status'] == 'PartiallyShipped' }
  end

  def get_line_items(order_list)
    orders = []
    order_list.each_with_index do |order, index|
      new_order = Order.new(order, @config)

      item_response = @client.orders.list_order_items(amazon_order_id: order.amazon_order_id)

      item_response.order_items.each { |item| new_order.line_items << Item.new(item) }

      orders << new_order
      break if orders.size == 30
    end
    orders
  end
end


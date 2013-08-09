class AmazonClient

  def initialize(config, message)
    @client = MWS.new(aws_access_key_id: config['amazon.aws_access_key'],
                      secret_access_key: config['amazon.secret_key'],
                      seller_id:         config['amazon.seller_id'],
                      marketplace_id:    config['amazon.marketplace_id'])
    @last_updated = config['amazon.last_updated_after']
    @config = config
    @orders = []
  end

  def get_orders
    statuses = %w(Unshipped PartiallyShipped Shipped)
    order_list = @client.orders.list_orders(last_updated_after: @last_updated, order_status: statuses)

    if order_list.orders.nil?
      nil
    elsif order_list.orders.is_a? MWS::API::Response
      get_line_items([order_list.orders])
    else
      get_line_items(order_list.orders)
    end

    @orders
  end

  private
  def get_line_items(order_list)
    order_list.each_with_index do |order, index|
      new_order = Order.new(order)

      item_response = @client.orders.list_order_items(amazon_order_id: order.amazon_order_id)

      item_response.order_items.each { |item| new_order.line_items << Item.new(item) }

      @orders << new_order
      break if @orders.size == 30
    end
  end
end
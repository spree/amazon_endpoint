class AmazonClient
  def initialize(config, message)
    @client = MWS.new(aws_access_key_id: config['amazon.aws_access_key'],
                      secret_access_key: config['amazon.secret_key'],
                      seller_id:         config['amazon.seller_id'],
                      marketplace_id:    config['amazon.marketplace_id'])
    @last_updated = config['amazon.last_updated_after']
    @config = config
  end

  def order_by_number(amazon_order_id)
    order_list = @client.orders.get_order(amazon_order_id: amazon_order_id)

    filtered_orders_hash = filter_orders(order_list.orders)

    order_line_items(filtered_orders_hash).first
  end

  def orders
    statuses = %w(Unshipped PartiallyShipped)

    order_list = @client.orders.list_orders(last_updated_after: @last_updated, order_status: statuses)

    filtered_orders_hash = filter_orders(order_list.orders)

    order_line_items(filtered_orders_hash)
  end

  def inventory_by_sku(sku)
    inventories = @client.inventory.list_inventory_supply(seller_skus: [sku])
    inventory_items(inventories).first
  end

  private

  def filter_orders(orders)
    orders = [orders] if orders.is_a? MWS::API::Response
    orders = remove_partially_shipped(orders)
    remove_amazon_fulfilled_orders(orders)
  end

  def remove_amazon_fulfilled_orders(orders)
    orders.to_a.
      reject { |order_hash| order_hash['fulfillment_channel'] != 'MFN' }
  end

  def remove_partially_shipped(orders)
    orders.to_a.
      reject { |order_hash| order_hash['order_status'] == 'PartiallyShipped' }
  end

  def order_line_items(order_list)
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

  def inventory_items(inventories)
    inventories['inventory_supply_list'].to_a.map { |inventory| Inventory.new(inventory) }
  end
end


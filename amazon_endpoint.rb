Dir['./lib/**/*.rb'].each &method(:require)

class AmazonEndpoint < EndpointBase
  set :logging, true

  post '/get_orders' do
    amazon_client = AmazonClient.new(@config, @message)
    @base_response = { message_id: @message[:message_id] }


    begin
      orders = amazon_client.orders
      if orders.any?
        # updates last_updated_at
        parameters = { parameters: [{ name: 'amazon.last_updated_after',
                                      value: orders.last.last_update_date }] }

        response = Builder.new(orders).build_response(parameters)
      end

      code = 200
    rescue => e
      code, response = handle_error(e)
    end

    process_result code, @base_response.merge(response.to_h)
  end

  post '/get_order_by_number' do
    amazon_client = AmazonClient.new(@config, @message)
    @base_response = { message_id: @message[:message_id] }

    begin
      order = amazon_client.order_by_number(@message[:payload]['amazon_order_id'])
      response = Builder.new(order).build_response
      code = 200
    rescue => e
      code, response = handle_error(e)
    end

    process_result code, @base_response.merge(response.to_h)
  end

  post '/get_inventory_by_sku' do
    amazon_client = AmazonClient.new(@config, @message)
    @base_response = { message_id: @message[:message_id] }

    begin
      inventory = amazon_client.inventory_by_sku(@message[:payload]['sku'])
      response = Builder.new(inventory).build_response
      code = 200
    rescue => e
      code, response = handle_error(e)
    end

    process_result code, @base_response.merge(response.to_h)
  end

  post '/confirm_shipment' do
    feed = AmazonFeed.new(@config)
    @base_response = { message_id: @message[:message_id] }

    begin
      order = Feeds::OrderFulfillment.new(@message[:payload]['shipment'], @config['amazon.seller_id'])
      response = feed.submit(order.feed_type, order.to_xml)
      code = 200
    rescue Feeds::RequestThrottled => e
      response = { delay: e.delay_in_seconds }
      code = 200
    rescue Feeds::QuotaExceeded => e
      response = { delay: e.reset_quota_in_seconds }
      code = 200
    rescue => e
      code, response = handle_error(e)
    end

    process_result code, @base_response.merge(response.to_h)
  end

  post '/feed_status' do
    feed = AmazonFeed.new(@config)
    @base_response = { message_id: @message[:message_id] }

    begin
      response = feed.status(@message[:payload]['feed_id'])
      code = 200
    rescue Feeds::FeedProcessingResultNotReady => e
      response = { delay: 2.minutes }
      code = 200
    rescue Feeds::RequestThrottled => e
      response = { delay: e.delay_in_seconds }
      code = 200
    rescue Feeds::QuotaExceeded => e
      response = { delay: e.reset_quota_in_seconds }
      code = 200
    rescue => e
      code, response = handle_error(e)
    end

    process_result code, @base_response.merge(response.to_h)
  end

  post '/update_inventory_availabitity' do
    feed = AmazonFeed.new(@config)
    @base_response = { message_id: @message[:message_id] }

    begin
      inventory = Feeds::InventoryAvailabitity.new(@message[:payload], @config['amazon.seller_id'])
      response = feed.submit(inventory.feed_type, inventory.to_xml)
      code = 200
    rescue Feeds::RequestThrottled => e
      response = { delay: e.delay_in_seconds }
      code = 200
    rescue Feeds::QuotaExceeded => e
      response = { delay: e.reset_quota_in_seconds }
      code = 200
    rescue => e
      code, response = handle_error(e)
    end

    process_result code, @base_response.merge(response.to_h)
  end

  private

  def handle_error(e)
    response = { notifications: [ { level:       'error',
                                    subject:     e.message,
                                    description: e.backtrace.to_a.join('\n\t') }] }
    [500, response]
  end
end


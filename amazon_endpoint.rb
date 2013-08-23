Dir['./lib/**/*.rb'].each { |f| require f }

class AmazonEndpoint < EndpointBase

  set :logging, true

  post '/get_orders' do
    amazon_client = AmazonClient.new(@config, @message)
    @base_response = { message_id: @message[:message_id] }

    begin
      orders = amazon_client.get_orders
      response = Builder.new(orders).build_response
      code = 200
    rescue => e
      code, response = handle_error(e)
    end

    process_result code, merged_response(response)
  end

  # "message": "amazon:import:by_number"
  # "payload": { "amazon_order_id": "103-123123-123123" }
  post '/get_order_by_number' do
    amazon_client = AmazonClient.new(@config, @message)
    @base_response = { message_id: @message[:message_id] }

    begin
      orders = amazon_client.get_order_by_number(@message[:payload]['amazon_order_id'])
      response = Builder.new(orders).build_response
      code = 200
    rescue => e
      code, response = handle_error(e)
    end

    process_result code, merged_response(response)
  end

  private

  def handle_error(e)
    response = { notifications: [ { level:       'error',
                                    subject:     e.message,
                                    description: e.backtrace.to_a.join('\n\t') }] }
    [500, response]
  end

  def merged_response(response)
    @base_response.merge(response.to_h)
  end
end


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
      response = {'error' => "#{e.message} ------- #{e.backtrace.to_a.join('\n\t')}"}
      code = 500
    end

    process_result code, merged_response(response)
  end

  def merged_response(response)
    response == nil ? @base_response : @base_response.merge(response)
  end
end


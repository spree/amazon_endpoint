Dir['./lib/**/*.rb'].each { |f| require f }

class AmazonEndpoint < EndpointBase

  set :logging, true

  post '/get_orders' do
    amazon_client = AmazonClient.new(@config, @message)
    @base_response = { message_id: @message[:message_id] }

    begin
      response = amazon_client.get_orders
      code = 200
    rescue => e
      code = 500
      response = {'error' => "#{e.backtrace} ------- #{e.message}"}
    end

    process_result code, merged_response(response)
  end

  def merged_response(response)
    response == nil ? @base_response : @base_response.merge(response)
  end
end

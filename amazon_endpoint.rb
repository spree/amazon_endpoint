Dir['./lib/**/*.rb'].each { |f| require f }

class AmazonEndpoint < EndpointBase

  set :logging, true

  post '/get_orders' do
    amazon_client = AmazonClient.new(@config, @message)

    begin
      response = amazon_client.get_orders
      code = 200
    rescue => e
      code = 500
      response = {'error' => e.message}
    end

    process_result code, response
  end
end

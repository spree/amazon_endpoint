Dir['./lib/**/*.rb'].each { |f| require f }

class AmazonEndpoint < EndpointBase

  set :logging, true

  post '/import_orders' do
    amazon_client = AmazonClient.new(credentials)
    orders = amazon_client.get_orders(created_after)

    process_result 200, {message_id: @message[:message_id]}.merge(orders)
  end

  private
  def created_after
    @config['created_after']
  end
  
  def credentials
    { 
      aws_access_key_id: @config['aws_access_key'], 
      secret_access_key: @config['secret_key'],
      seller_id: @config['seller_id'], 
      marketplace_id: @config['marketplace_id'] 
    }
  end
end
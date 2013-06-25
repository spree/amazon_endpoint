require 'spec_helper'

describe AmazonEndpoint do

  let(:config) { [{ name: "marketplace_id", value: 'ATVPDKIKX0DER'}, 
                  { name: "seller_id", value: 'A6WWS5LKYVEJ8'}, 
                  { name: 'last_created_after', value: '2013-06-12'}, 
                  { name: 'aws_access_key', value: 'AKIAIR24VLFSLJRUCXBQ'}, 
                  { name: 'secret_key', value: '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'}] }

  let(:message) {{ message_id: '1234567' }}

  let(:request) {{ message: 'amazon:order:poll', 
                     message_id: '1234567', 
                     payload: 
                       { parameters: config }}}
  
  def auth
    {'HTTP_X_AUGURY_TOKEN' => 'x123', "CONTENT_TYPE" => "application/json"}
  end

  def app
    AmazonEndpoint
  end

  before do
    @amazon_client = double 
    AmazonClient.should_receive(:new).with(config, message).and_return(@amazon_client)
  end

  it 'gets orders from amazon' do
    @amazon_client.should_receive(:get_orders).and_return(hash_including 'message' => ('spree:import:order'))

    post '/get_orders', request.to_json, auth
    
    last_response.status.should == 200    
  end   
end
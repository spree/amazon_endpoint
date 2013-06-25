require 'spec_helper'

describe AmazonEndpoint do

  let(:config) { [{ name: "marketplace_id", value: 'abc1'}, 
                  { name: "seller_id", value: 'abc2'}, 
                  { name: 'created_after', value: '2013-06-12'}, 
                  { name: 'aws_access_key', value: 'abc12'}, 
                  { name: 'secret_key', value: 'abc123'}] }

  let(:message) { message_id: '1234567'}
  
  def auth
    {'HTTP_X_AUGURY_TOKEN' => 'x123', "CONTENT_TYPE" => "application/json"}
  end

  def app
    AmazonEndpoint
  end

  def creds
    { marketplace_id: 'abc1', seller_id: 'abc2', aws_access_key: 'abc12', secret_key: 'abc123' }
  end

  before do
    @amazon_client = double 
    AmazonClient.should_recieve(:new).with(creds).and_return(@amazon_client)
  end

end
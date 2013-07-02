require 'spec_helper'

describe AmazonEndpoint do

  let(:config) { [{ name: "amazon.marketplace_id", value: 'ATVPDKIKX0DER'},
                  { name: "amazon.seller_id", value: 'A6WWS5LKYVEJ8'},
                  { name: 'amazon.last_created_after', value: '2013-06-12'},
                  { name: 'amazon.aws_access_key', value: 'AKIAIR24VLFSLJRUCXBQ'},
                  { name: 'amazon.secret_key', value: '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'}] }

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
   Timecop.freeze('2013-06-25T15:56:31-04:00')
  end

  after do
   Timecop.return
  end

  it 'gets orders from amazon' do
   VCR.use_cassette('amazon_client_valid_orders') do
     post '/get_orders', request.to_json, auth

     last_response.status.should == 200
     last_response.body.should match /1234567/
   end
  end
end

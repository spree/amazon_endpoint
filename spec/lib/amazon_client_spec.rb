require 'spec_helper'

describe AmazonClient do
  let(:config) { { 'amazon.marketplace_id' => 'ATVPDKIKX0DER',
                 "amazon.seller_id" =>  'A6WWS5LKYVEJ8',
                 'amazon.last_updated_after' =>  '',
                 'amazon.aws_access_key' =>  'AKIAIR24VLFSLJRUCXBQ',
                 'amazon.secret_key' =>  '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' } }

  let(:message) { { message_id: 'XXX' } }

  before do
   Timecop.freeze('2013-07-12 14:35:14-04:00')
  end

  after do
   Timecop.return
  end

  it 'gets multiple orders from amazon' do
    VCR.use_cassette('amazon_client_valid_orders') do
      config['amazon.last_updated_after'] = '2013-06-12'
      client = AmazonClient.new(config, message)

      orders = client.get_orders
      orders.count.should > 1
   end
  end

  it 'gets one order from amazon' do
    VCR.use_cassette('amazon_client_valid_one_order') do
      config['amazon.last_updated_after'] = '2013-07-11'
      client = AmazonClient.new(config, message)

      orders = client.get_orders
      orders.count.should == 1
    end
  end

  it 'gets no orders from amazon' do
    VCR.use_cassette('amazon_client_valid_no_orders') do
      config['amazon.last_updated_after'] = '2013-07-12T13:58:55Z'
      client = AmazonClient.new(config, message)

      orders = client.get_orders
      orders.empty?.should eq true
    end
  end
end

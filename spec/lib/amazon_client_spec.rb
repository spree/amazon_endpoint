require 'spec_helper'

describe AmazonClient do
  let(:config) { { 'amazon.marketplace_id' => 'ATVPDKIKX0DER',
                 "amazon.seller_id" =>  'A6WWS5LKYVEJ8',
                 'amazon.last_updated_after' =>  '',
                 'amazon.aws_access_key' =>  'AKIAIR24VLFSLJRUCXBQ',
                 'amazon.secret_key' =>  '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' } }

  let(:message) { { message_id: 'XXX' } }

  before do
   Timecop.freeze('2013-07-02T16:23:22-04:00')
  end

  after do
   Timecop.return
  end

  it 'gets multiple orders from amazon' do
    VCR.use_cassette('amazon_client_valid_orders') do
      config['amazon.last_updated_after'] = '2013-06-12'
      client = AmazonClient.new(config, message)

      response = client.get_orders
      response[:messages].first[:payload][:order][:amazon_order_id].should eq '111-6494089-5358640'
      response[:messages].first[:payload][:order][:line_items].first[:name].should eq 'Munchkin 5 Pack Multi Bowl'
   end
  end

  it 'gets one order from amazon' do
    VCR.use_cassette('amazon_client_valid_one_order') do
      config['amazon.last_updated_after'] = '2013-06-18'
      client = AmazonClient.new(config, message)

      response = client.get_orders
      response[:messages].count.should == 1
      response[:messages][0][:message].should eq 'order:new'
    end
  end

  it 'gets no orders from amazon' do
    VCR.use_cassette('amazon_client_valid_no_orders') do
      config['amazon.last_updated_after'] = '2013-06-21'
      client = AmazonClient.new(config, message)

      response = client.get_orders
      response.should eq nil
    end
  end
end

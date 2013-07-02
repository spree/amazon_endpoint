require 'spec_helper'

describe AmazonClient do
  let(:config) { { 'amazon.marketplace_id' => 'ATVPDKIKX0DER',
                 "amazon.seller_id" =>  'A6WWS5LKYVEJ8',
                 'amazon.last_created_after' =>  '2013-06-12',
                 'amazon.aws_access_key' =>  'AKIAIR24VLFSLJRUCXBQ',
                 'amazon.secret_key' =>  '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' } }

  let(:message) { { message_id: 'XXX' } }

  subject { AmazonClient.new(config, message) }

  before do
   Timecop.freeze('2013-06-25T15:56:31-04:00')
  end

  after do
   Timecop.return
  end

  it 'gets orders from amazon' do
    #config['last_created_after'] = '2013-06-12'
    #binding.pry
    #client = AmazonClient.new(config, message)
    
    VCR.use_cassette('amazon_client_valid_orders') do
     response = subject.get_orders
     response[:messages].first[:payload][:order][:amazon_order_id].should eq '111-6494089-5358640'
     response[:messages].first[:payload][:order][:line_items].first[:name].should eq 'Munchkin 5 Pack Multi Bowl'
   end
  end
end

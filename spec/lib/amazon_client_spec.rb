require 'spec_helper'

describe AmazonClient do
  let(:config) { { 'marketplace_id' => 'ATVPDKIKX0DER',
                 "seller_id" =>  'A6WWS5LKYVEJ8',
                 'last_created_after' =>  '2013-06-12',
                 'aws_access_key' =>  'AKIAIR24VLFSLJRUCXBQ',
                 'secret_key' =>  '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' } }

  let(:message) { { message_id: 'XXX' } }

  subject { AmazonClient.new(config, message) }

  it 'gets orders from amazon' do
   VCR.use_cassette('amazon_client_valid_orders', record: :all) do
     response = subject.get_orders
     response[:messages].first[:payload][:order][:amazon_order_id].should eq '111-6494089-5358640'
     response[:messages].first[:payload][:order][:line_items].first[:name].should eq 'Munchkin 5 Pack Multi Bowl'
   end
  end
end

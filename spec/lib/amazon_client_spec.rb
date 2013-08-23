require 'spec_helper'

describe AmazonClient do
  let(:config) { { 'amazon.marketplace_id'     => 'ATVPDKIKX0DER',
                   "amazon.seller_id"          =>  'A6WWS5LKYVEJ8',
                   'amazon.last_updated_after' =>  '',
                   'amazon.aws_access_key'     =>  'AKIAIR24VLFSLJRUCXBQ',
                   'amazon.secret_key'         =>  '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' } }

  let(:message) { { message_id: 'XXX' } }

  before { Timecop.freeze('2013-08-16 08:55:14-05:00') }
  after  { Timecop.return }

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
      config['amazon.last_updated_after'] = '2013-07-15'
      client = AmazonClient.new(config, message)

      orders = client.get_orders
      expect(orders).to have(1).items
    end
  end

  it 'gets no orders from amazon' do
    VCR.use_cassette('amazon_client_valid_no_orders') do
      config['amazon.last_updated_after'] = '2013-08-16T09:55:14Z'
      client = AmazonClient.new(config, message)

      orders = client.get_orders
      expect(orders).to be_empty
    end
  end

  context 'when fulfillment_channel is not MFN' do
    it 'ignores orders' do
      VCR.use_cassette('amazon_client_fulfillment_channel_mfn') do
        config['amazon.last_updated_after'] = '2013-07-15'
        client = AmazonClient.new(config, message)

        orders = client.get_orders
        expect(orders).to be_empty
      end
    end
  end

  describe '#get_order_by_number' do
    before { Timecop.freeze('2013-08-23 17:25:14-05:00') }
    after  { Timecop.return }
    it 'gets order by number' do
      VCR.use_cassette('amazon_client_valid_order_by_number') do
        client = AmazonClient.new(config, message)

        orders = client.get_order_by_number('102-1580746-9061828')
        expect(orders).to have(1).items
      end
    end
  end
end

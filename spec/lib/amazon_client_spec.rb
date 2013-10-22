require 'spec_helper'

describe AmazonClient do

  let(:config) { { 'amazon.marketplace_id'     => ENV['MWS_MARKETPLACE'],
                   "amazon.seller_id"          => ENV['MWS_MERCHANT'],
                   'amazon.aws_access_key'     => ENV['MWS_KEY'],
                   'amazon.secret_key'         => ENV['MWS_SECRET_KEY'],
                   'amazon.last_updated_after' => '' } }

  let(:message) { { message_id: 'XXX' } }

  describe '#orders' do
    before do
      now = Time.new(2013, 8, 16, 10, 55, 14, "-03:00")
      Timecop.freeze(now)
    end

    after  { Timecop.return }

    it 'gets multiple orders from amazon' do
      VCR.use_cassette('amazon_client_valid_orders') do
        config['amazon.last_updated_after'] = '2013-06-12'
        client = AmazonClient.new(config, message)

        expect(client.orders).to have(2).items
      end
    end

    it 'gets one order from amazon' do
      VCR.use_cassette('amazon_client_valid_one_order') do
        config['amazon.last_updated_after'] = '2013-07-15'
        client = AmazonClient.new(config, message)

        expect(client.orders).to have(1).item
      end
    end

    it 'gets no orders from amazon' do
      VCR.use_cassette('amazon_client_valid_no_orders') do
        config['amazon.last_updated_after'] = '2013-08-16T09:55:14Z'
        client = AmazonClient.new(config, message)

        expect(client.orders).to be_empty
      end
    end

    context 'when fulfillment_channel is not MFN' do
      it 'ignores orders' do
        VCR.use_cassette('amazon_client_fulfillment_channel_mfn') do
          config['amazon.last_updated_after'] = '2013-07-15'
          client = AmazonClient.new(config, message)

          expect(client.orders).to be_empty
        end
      end
    end
  end

  describe '#order_by_number' do
    before do
      now = Time.new(2013, 8, 23, 19, 25, 14, '-03:00')
      Timecop.freeze(now)
    end

    after  { Timecop.return }

    it 'gets order by number' do
      VCR.use_cassette('amazon_client_valid_order_by_number') do
        client = AmazonClient.new(config, message)

        order = client.order_by_number('102-1580746-9061828')
        expect(order.to_message[:payload][:order][:number]).
          to eq('102-1580746-9061828')
      end
    end
  end

  describe '#inventory_by_sku' do
    before do
      now = Time.new(2013, 10, 21, 17, 30, 14, '-03:00')
      Timecop.freeze(now)
    end

    after  { Timecop.return }

    it 'returns inventory by sku' do
      VCR.use_cassette('amazon_client_inventory_by_sku') do
        client = AmazonClient.new(config, message)

        inventory = client.inventory_by_sku('OX-M0NP-AOD1')
        expect(inventory.to_message[:payload]).to eq({ sku: 'OX-M0NP-AOD1', quantity: '0' })
      end
    end
  end
end


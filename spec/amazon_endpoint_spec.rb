require 'spec_helper'

describe AmazonEndpoint do

  let(:config) { [{ name: "amazon.marketplace_id",     value: ENV['MARKETPLACE_ID'] },
                  { name: "amazon.seller_id",          value: ENV['SELLER_ID'] },
                  { name: 'amazon.last_updated_after', value: '2013-06-12' },
                  { name: 'amazon.aws_access_key',     value: ENV['AWS_ACCESS_KEY'] },
                  { name: 'amazon.secret_key',         value: ENV['SECRET_KEY'] }] }

  let(:message) { { message_id: '1234567' } }

  let(:request) { { message: 'amazon:order:poll',
                    message_id: '1234567',
                    payload: { parameters: config } } }

  def auth
    { 'HTTP_X_AUGURY_TOKEN' => 'x123', 'CONTENT_TYPE' => 'application/json' }
  end

  def app
    AmazonEndpoint
  end

  describe '/get_orders' do
    before do
      now = Time.new(2013, 8, 16, 10, 55, 14, '-03:00')
      # Timecop.freeze(now)
      Time.stub(now: now)
    end

    # after  { Timecop.return }

    it 'gets orders from amazon' do
      VCR.use_cassette('amazon_client_valid_orders') do
        post '/get_orders', request.to_json, auth

        expect(last_response).to be_ok
        expect(json_response['message_id']).to eq('1234567')
      end
    end
  end

  describe '/get_order_by_number' do
    before do
      now = Time.new(2013, 8, 23, 19, 25, 14, '-03:00')
      # Timecop.freeze(now)
      Time.stub(now: now)
    end

    # after  { Timecop.return }

    it 'gets order by number from amazon' do
      VCR.use_cassette('amazon_client_valid_order_by_number') do
        request[:payload][:amazon_order_id] = '102-1580746-9061828'
        post '/get_order_by_number', request.to_json, auth

        expect(last_response).to be_ok
        expect(json_response['message_id']).to eq('1234567')
      end
    end
  end

  describe '/get_inventory_by_sku' do
    before do
      now = Time.new(2013, 10, 21, 18, 30, 14, '-02:00')
      # Timecop.freeze(now)
      Time.stub(now: now)
    end

    # after  { Timecop.return }

    it 'gets inventory by sku from amazon' do
      VCR.use_cassette('amazon_client_inventory_by_sku') do
        request[:payload][:sku] = 'OX-M0NP-AOD1'
        post '/get_inventory_by_sku', request.to_json, auth

        expect(last_response).to be_ok
        expect(json_response['message_id']).to eq('1234567')
        expect(json_response['messages']).to have(1).item
        expect(json_response['messages'].first['payload']['sku']).to eq('OX-M0NP-AOD1')
      end
    end
  end

  describe '/confirm_shipment' do
    before do
      now = Time.new(2013, 10, 22, 15, 51, 11, '-04:00')
      # Timecop.freeze(now)
      Time.stub(now: now)
    end

    # after  { Timecop.return }

    xit 'confirms shipment' do
      VCR.use_cassette('submit_feed') do
        request[:payload][:shipment] = Factories.shipment
        post '/confirm_shipment', request.to_json, auth

        expect(last_response).to be_ok
        expect(json_response['message_id']).to eq('1234567')
        expect(json_response['messages']).to have(1).item
        expect(json_response['messages'].first['payload']['sku']).to eq('OX-M0NP-AOD1')
      end
    end
  end
end


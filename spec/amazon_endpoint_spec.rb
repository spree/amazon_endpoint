require 'spec_helper'

describe AmazonEndpoint do

  let(:config) { [{ name: 'amazon.marketplace_id',     value: ENV['MARKETPLACE_ID'] },
                  { name: 'amazon.seller_id',          value: ENV['SELLER_ID'] },
                  { name: 'amazon.aws_access_key',     value: ENV['AWS_ACCESS_KEY'] },
                  { name: 'amazon.secret_key',         value: ENV['SECRET_KEY'] },
                  { name: 'amazon.last_updated_after', value: '2013-06-12' }] }

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
      Time.stub(now: now)
    end

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
      Time.stub(now: now)
    end

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
      Time.stub(now: now)
    end

    it 'gets inventory by sku from amazon' do
      VCR.use_cassette('amazon_client_inventory_by_sku') do
        request[:payload][:sku] = 'OX-M0NP-AOD1'
        post '/get_inventory_by_sku', request.to_json, auth

        expect(last_response).to be_ok
        expect(json_response['message_id']).to eq('1234567')
        expect(json_response['messages']).to have(1).item
        expect(json_response['messages'].first).to include({ 'payload' => { 'sku' => 'OX-M0NP-AOD1', 'quantity' => '0' } })
      end
    end
  end

  describe '/feed_status' do
    before do
      now = Time.new(2013, 10, 22, 21, 39, 01, '-04:00')
      Time.stub(now: now)
    end

    it 'gets feed status' do
      VCR.use_cassette('feed_status') do
        request = { message_id: '1234', message: 'amazon:feed:status',
                    payload: { feed_id: '8253017998', parameters: config } }

        post '/feed_status', request.to_json, auth
        expect(last_response).to be_ok
        expect(json_response['message_id']).to eq('1234')
        expect(json_response['notifications']).to have(1).item
        expect(json_response['notifications'].first['description']).to eq('Succesfully processed feed #8253017998')
      end
    end

    context 'when throttled' do
      it 'rescheduler the original message' do
        AmazonFeed.any_instance.stub(:status).and_raise(Feeds::RequestThrottled)
        Feeds::RequestThrottled.any_instance.stub(delay_in_seconds: 8.minutes)

        request = { message_id: '1234', message: 'amazon:feed:status',
                    payload: { feed_id: '8253017998', parameters: config } }

        post '/feed_status', request.to_json, auth

        expect(last_response).to be_ok
        expect(json_response['message_id']).to eq('1234')
        expect(json_response['delay']).to eq 8.minutes
        expect(json_response).to_not have_key('messages')
        expect(json_response).to_not have_key('notifications')
      end
    end

    context 'when request quota exceeded' do
      it 'rescheduler the original message' do
        AmazonFeed.any_instance.stub(:status).and_raise(Feeds::QuotaExceeded)

        request = { message_id: '1234', message: 'amazon:feed:status',
                    payload: { feed_id: '8253017998', parameters: config } }

        post '/feed_status', request.to_json, auth

        expect(last_response).to be_ok
        expect(json_response['message_id']).to eq('1234')
        expect(json_response['delay']).to eq 20.minutes
        expect(json_response).to_not have_key('messages')
        expect(json_response).to_not have_key('notifications')
      end
    end

    context 'when errors' do
      before do
        now = Time.new(2013, 10, 23, 14, 44, 11, '-03:00')
        Time.stub(now: now)
      end

      it 'returns a notification error' do
        VCR.use_cassette('inventory_feed_status_error') do
          request = { message_id: '1234', message: 'amazon:feed:status',
                      payload: { feed_id: '8259737688', parameters: config } }

          post '/feed_status', request.to_json, auth
          expect(last_response).to_not be_ok
          expect(json_response['message_id']).to eq('1234')
          expect(json_response).to_not have_key('messages')
          expect(json_response['notifications']).to have(1).item
          expect(json_response['notifications'].first['subject']).to include('This SKU does not exist in the Amazon.com catalog')
        end
      end
    end

    context 'when not processed' do
      before do
        now = Time.new(2013, 10, 23, 14, 44, 11, '-03:00')
        Time.stub(now: now)
      end

      it 're-schedules message status checker' do
        VCR.use_cassette('inventory_feed_status_not_processed') do
          request = { message_id: '1234',
                      message: 'amazon:feed:status',
                      payload: { feed_id: '8259716402', parameters: config } }


          post '/feed_status', request.to_json, auth
          expect(last_response).to be_ok
          expect(json_response['message_id']).to eq '1234'
          expect(json_response['delay']).to eq 2.minutes
          expect(json_response).to_not have_key('notifications')
          expect(json_response).to_not have_key('messages')
        end
      end
    end
  end

  describe '/confirm_shipment' do
    before do
      now = Time.new(2013, 10, 22, 15, 51, 11, '-04:00')
      Time.stub(now: now)
    end

    it 'confirms shipment' do
      VCR.use_cassette('submit_feed') do
        request[:payload][:shipment] = Factories.shipment
        post '/confirm_shipment', request.to_json, auth

        expect(last_response).to be_ok
        expect(json_response['message_id']).to eq('1234567')
        expect(json_response['messages']).to have(1).item
        expect(json_response['messages'].first).to eq('message' => 'amazon:feed:status', 'payload' => { 'feed_id' => '8253017998' }, 'delay' => 2.minutes)
      end
    end

    context 'when throttled' do
      it 'rescheduler the original message' do
        AmazonFeed.any_instance.stub(:submit).and_raise(Feeds::RequestThrottled)
        Feeds::RequestThrottled.any_instance.stub(delay_in_seconds: 12.minutes)

        request[:payload][:shipment] = Factories.shipment

        post '/confirm_shipment', request.to_json, auth

        expect(last_response).to be_ok
        expect(json_response['message_id']).to eq('1234567')
        expect(json_response['delay']).to eq 12.minutes
        expect(json_response).to_not have_key('messages')
        expect(json_response).to_not have_key('notifications')
      end
    end

    context 'when quota exceeded' do
      it 'rescheduler the original message' do
        AmazonFeed.any_instance.stub(:submit).and_raise(Feeds::QuotaExceeded)

        request[:payload][:shipment] = Factories.shipment

        post '/confirm_shipment', request.to_json, auth

        expect(last_response).to be_ok
        expect(json_response['message_id']).to eq('1234567')
        expect(json_response['delay']).to eq 20.minutes
        expect(json_response).to_not have_key('messages')
        expect(json_response).to_not have_key('notifications')
      end
    end
  end

  describe '/update_inventory_availabitity' do
    before do
      now = Time.new(2013, 10, 23, 14, 41, 11, '-03:00')
      Time.stub(now: now)
    end

    it 'updates inventory availability' do
      VCR.use_cassette('submit_item_feed') do
        request[:payload].merge!(Factories.item)

        post '/update_inventory_availabitity', request.to_json, auth

        expect(last_response).to be_ok
        expect(json_response['message_id']).to eq('1234567')
        expect(json_response['messages']).to have(1).item
        expect(json_response['messages'].first).to eq('message' => 'amazon:feed:status', 'payload' => { 'feed_id' => '8259603164' }, 'delay' => 2.minutes)
      end
    end

    context 'when quota exceeded' do
      it 'rescheduler the original message' do
        AmazonFeed.any_instance.stub(:submit).and_raise(Feeds::QuotaExceeded)

        request[:payload].merge!(Factories.item)

        post '/update_inventory_availabitity', request.to_json, auth

        expect(last_response).to be_ok
        expect(json_response['message_id']).to eq('1234567')
        expect(json_response['delay']).to eq 20.minutes
        expect(json_response).to_not have_key('messages')
        expect(json_response).to_not have_key('notifications')
      end
    end

    context 'when throttled' do
      it 'rescheduler the original message' do
        AmazonFeed.any_instance.stub(:submit).and_raise(Feeds::RequestThrottled)
        Feeds::RequestThrottled.any_instance.stub(delay_in_seconds: 20.minutes)

        request[:payload].merge!(Factories.item)

        post '/update_inventory_availabitity', request.to_json, auth

        expect(last_response).to be_ok
        expect(json_response['message_id']).to eq('1234567')
        expect(json_response['delay']).to eq 20.minutes
        expect(json_response).to_not have_key('messages')
        expect(json_response).to_not have_key('notifications')
      end
    end
  end
end


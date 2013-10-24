require 'spec_helper'

module Feeds
  describe AmazonFeed do
    let(:config) {{ 'amazon.aws_access_key' => ENV['AWS_ACCESS_KEY'],
                    'amazon.secret_key'     => ENV['SECRET_KEY'],
                    'amazon.seller_id'      => ENV['SELLER_ID'] } }

    describe '#submit' do
      context 'when order' do
        before do
          now = Time.new(2013, 10, 22, 15, 51, 11, '-04:00')
          # Timecop.freeze(now)
          Time.stub(now: now)
        end

        it 'should submit a feed' do
          VCR.use_cassette('submit_feed') do
            order = OrderFulfillment.new(Factories.shipment, ENV['SELLER_ID'])
            res = AmazonFeed.new(config).submit(order.feed_type, order.to_xml)
            expect(res[:messages].first[:message]).to eq 'amazon:feed:status'
            expect(res[:messages].first[:payload][:feed_id]).to eq '8253017998'
          end
        end
      end

      context 'when inventory_availabitity' do
        before do
          now = Time.new(2013, 10, 23, 14, 41, 11, '-03:00')
          # Timecop.freeze(now)
          Time.stub(now: now)
        end

        it 'should submit a feed' do
          VCR.use_cassette('submit_item_feed') do
            item = InventoryAvailabitity.new(Factories.item, ENV['SELLER_ID'])
            res = AmazonFeed.new(config).submit(item.feed_type, item.to_xml)
            expect(res[:messages].first[:message]).to eq 'amazon:feed:status'
            expect(res[:messages].first[:payload][:feed_id]).to eq '8259603164'
          end
        end
      end
    end

    describe '#status' do
      context 'when order' do
        before do
          now = Time.new(2013, 10, 22, 21, 39, 01, '-04:00')
          # Timecop.freeze(now)
          Time.stub(now: now)
        end

        # after  { Timecop.return }

        it 'should return the status of a feed' do
          VCR.use_cassette('feed_status') do
            res = AmazonFeed.new(config).status('8253017998')
            expect(res[:notifications].first[:description]).to eq 'Succesfully processed feed #8253017998'
          end
        end
      end

      context 'when inventory_availabitity' do
        before do
          now = Time.new(2013, 10, 23, 14, 44, 11, '-03:00')
          # Timecop.freeze(now)
          Time.stub(now: now)
        end

        # after  { Timecop.return }

        it 'should return the status of a feed' do
          VCR.use_cassette('inventory_feed_status') do
            res = AmazonFeed.new(config).status('8259593438')
            expect(res[:notifications].first[:description]).to eq 'Succesfully processed feed #8259593438'
          end
        end

        context 'and not processed' do
          it 'returns feed status query' do
            VCR.use_cassette('inventory_feed_status_not_processed') do
              expect { AmazonFeed.new(config).status('8259716402') }.to raise_error(FeedProcessingResultNotReady)
            end
          end
        end

        context 'and errors' do
          it 'returns notification errors' do
            VCR.use_cassette('inventory_feed_status_error') do
              expect { AmazonFeed.new(config).status('8259737688') }.to raise_error(SubmissionError)
            end
          end
        end
      end
    end
  end
end


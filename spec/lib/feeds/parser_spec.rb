require 'spec_helper'

module Feeds
  describe Parser do

    describe '#parse_submission' do
      context 'successful response' do
        it 'should return feed:status message' do
          msg = Parser.parse_submission(Responses.successful_submission)
          expect(msg).to eq({ messages: [message: 'amazon:feed:status', payload: { feed_id: '8253017998' }, delay: 120] })
        end
      end

      context 'when unsuccessful response' do
        it 'raise SubmissionError' do
          expect { Parser.parse_submission(Responses.submission_error) }.to raise_error(SubmissionError)
        end
      end

      context 'when request throttled' do
        it 'raises RequestThrottled' do
          expect { Parser.parse_submission(Responses.request_throttled) }.to raise_error(RequestThrottled)
        end
      end

      context 'when request quota_exceeded' do
        it 'raises QuotaExceeded' do
          expect { Parser.parse_submission(Responses.request_quota_exceeded) }.to raise_error(QuotaExceeded)
        end
      end
    end

    describe '#parse_result' do
      context 'when error processing feed' do
        it 'raises SubmissionError' do
          expect { Parser.parse_result('8252984128', Responses.status_error) }.to raise_error(SubmissionError)
        end
      end

      context 'when not processed' do
        it 'raises FeedProcessingResultNotReady' do
          expect { Parser.parse_result('8252984128', Responses.submission_not_processed) }.to raise_error(FeedProcessingResultNotReady)
        end
      end

      context 'when request throttled' do
        it 'raises RequestThrottled' do
          expect { Parser.parse_result('8252984128', Responses.request_throttled) }.to raise_error(RequestThrottled)
        end
      end

      context 'when request quota_exceeded' do
        it 'raises QuotaExceeded' do
          expect { Parser.parse_result('8252984128', Responses.request_quota_exceeded) }.to raise_error(QuotaExceeded)
        end
      end

      context 'successfully processed' do
        it 'returns successfully notification' do
          message = Parser.parse_result('8253017998', Responses.successful_result)
          expected = { :notifications =>
                       [{ :level       => 'info',
                          :subject     => 'Feed Complete',
                          :description => 'Succesfully processed feed #8253017998' }] }
          expect(message).to eq expected
        end
      end
    end
  end

  describe Feeds::QuotaExceeded do
    describe '#reset_quota_in_seconds' do
      before do
        now = Time.new(2013, 10, 24, 01, 00, 00, '+00:00')
        Time.stub(now: now)
      end

      it 'returns next reset quota' do
        e = described_class.
          new('You exceeded your quota of 30.0 requests per 1 hour for operation Feeds/2009-01-01/SubmitFeed.  Your quota will reset on Thu Oct 24 01:30:00 UTC 2013')
        expect(e.reset_quota_in_seconds).to eq 30.minutes
      end

      context 'when regex does not match' do
        it 'returns default' do
          e = described_class.new('I am Amazon MWS trolling you with an unexpected QuotaExceeded message')
          expect(e.reset_quota_in_seconds).to eq 20.minutes
        end
      end
    end
  end

  describe Feeds::RequestThrottled do
    describe '#delay_in_seconds' do
      it 'returns a random delay 8..20' do
        e = described_class.new
        e.stub(:rand).with(8..20).and_return(1)
        expect(e.delay_in_seconds).to eq 1.minute
      end
    end
  end
end


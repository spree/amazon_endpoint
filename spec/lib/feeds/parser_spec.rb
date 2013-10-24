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
end


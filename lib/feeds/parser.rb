module Feeds
  class SubmissionError < StandardError; end

  class Parser
    class << self

      def parse_submission(response)
        doc = Nokogiri::XML(response).remove_namespaces!
        raise SubmissionError, doc.xpath('//Message').text if doc.root.name == 'ErrorResponse'
        id = doc.xpath('//FeedSubmissionId').text
        status_message(id)
      end

      def parse_result(feed_id, response)
        doc = Nokogiri::XML(response).remove_namespaces!
        errors = doc.xpath('//MessagesWithError').text.to_i

        case
        when doc.xpath('//Code').text == 'FeedProcessingResultNotReady'
          # Not ready, check again later
          status_message(feed_id)
        when errors > 0
          # Errors while processing the feed
          msg = doc.xpath('//ResultDescription').text
          error_result(feed_id, msg)
        else
          msg = successful_result(feed_id)
        end
      end

      private

      def status_message(id)
        { messages:
          [ message: 'amazon:feed:status',
            payload: { feed_id: id }]
        }
      end

      def successful_result(id)
        { notifications:
          [{ level: 'info',
             subject: 'Feed Complete',
             description: "Succesfully processed feed ##{id}" }]
        }
      end

      def error_result(id, msg)
        { notifications:
          [{ level: 'error',
             subject: 'Feed Error',
             description: "Feed ##{id} Not Processed. #{msg}" }]
        }
      end
    end
  end
end

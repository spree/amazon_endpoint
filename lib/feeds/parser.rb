module Feeds
  class SubmissionError < StandardError; end
  class RequestThrottled < StandardError; end
  class FeedProcessingResultNotReady < StandardError; end
  class QuotaExceeded < StandardError
    def reset_quota_in_minutes
      @reset_quota_in_minutes ||= begin
                                    if matches = /.+reset on (.+)/.match(message)
                                      return (Time.parse(matches[1]) - Time.now.utc).to_i
                                    end
                                    20.minutes
                                  end
    end
  end

  class Parser
    class << self

      def parse_submission(response)
        doc = Nokogiri::XML(response).remove_namespaces!
        validate!(doc)
        id = doc.xpath('//FeedSubmissionId').text
        status_message(id)
      end

      def parse_result(feed_id, response)
        doc = Nokogiri::XML(response).remove_namespaces!
        validate!(doc)
        successful_result(feed_id)
      end

      private

      def validate!(doc)
        case
        when doc.xpath('//Code').text == 'FeedProcessingResultNotReady'
          raise FeedProcessingResultNotReady, "#{doc.xpath('//Message').text}\n#{doc.to_s}"
        when doc.xpath('//Code').text == 'RequestThrottled'
          raise RequestThrottled, "#{doc.xpath('//Message').text}\n#{doc.to_s}"
        when doc.xpath('//Code').text == 'QuotaExceeded'
          raise QuotaExceeded, "#{doc.xpath('//Message').text}\n#{doc.to_s}"
        when doc.root.name == 'ErrorResponse'
          raise SubmissionError,  "#{doc.xpath('//Message').text}\n#{doc.to_s}"
        when doc.xpath('//MessagesWithError').text.to_i > 0
          raise SubmissionError,  "#{doc.xpath('//ResultDescription').text}\n#{doc.to_s}"
        end
      end

      def status_message(id)
        { messages:
          [ message: 'amazon:feed:status',
            payload: { feed_id: id },
            delay: 2.minutes ]
        }
      end

      def successful_result(id)
        { notifications:
          [{ level: 'info',
             subject: 'Feed Complete',
             description: "Succesfully processed feed ##{id}" }]
        }
      end
    end
  end
end


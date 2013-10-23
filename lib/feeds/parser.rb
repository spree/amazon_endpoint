module Feeds
  class Parser
    class << self

      def parse_submission(response)
        doc = Nokogiri::XML(response).remove_namespaces!
        raise SubmissionError, doc.xpath('//Message').text if doc.root.name == 'ErrorResponse'
        doc.xpath('//FeedSubmissionId').text
      end

      def parse_result(response)
        doc = Nokogiri::XML(response).remove_namespaces!
        errors = doc.xpath('//MessagesWithError').text.to_i
        id = doc.xpath('//DocumentTransactionID').text

        if errors > 0
          msg = doc.xpath('//ResultDescription').text
          error_result(id, msg)
        else
          msg = successful_result(id)
        end
      end

      private
      def successful_result(id)
        { notifications:
          [{ level: 'info',
             subject: 'Feed Complete',
             description: "Succesfully processed feed # #{id}" }]
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

  class SubmissionError < StandardError; end
end
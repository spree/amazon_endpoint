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

        if errors > 0
          #raise error or something
        else
          return doc.xpath('//DocumentTransactionID').text
        end
      end
    end
  end

  class SubmissionError < StandardError; end
end
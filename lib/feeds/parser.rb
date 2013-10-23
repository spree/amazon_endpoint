module Feeds
  class Parser
    class << self

      def parse_submission(response)
        doc = Nokogiri::XML(response).remove_namespaces!
        doc.xpath('//FeedSubmissionId').text
      end
    end
  end
end
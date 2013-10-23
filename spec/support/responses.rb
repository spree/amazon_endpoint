module Responses
  class << self

    def successful_submission
      '<?xml version="1.0"?><SubmitFeedResponse xmlns="http://mws.amazonaws.com/doc/2009-01-01/"><SubmitFeedResult><FeedSubmissionInfo><FeedSubmissionId>8253017998</FeedSubmissionId><FeedType>_POST_ORDER_FULFILLMENT_DATA_</FeedType><SubmittedDate>2013-10-22T19:57:09+00:00</SubmittedDate><FeedProcessingStatus>_SUBMITTED_</FeedProcessingStatus></FeedSubmissionInfo></SubmitFeedResult><ResponseMetadata><RequestId>5d9a8cbb-aba4-4df7-b89c-8851114caa8d</RequestId></ResponseMetadata></SubmitFeedResponse>'
    end
  end
end
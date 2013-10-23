module Responses
  class << self

    def successful_submission
      '<?xml version="1.0"?><SubmitFeedResponse xmlns="http://mws.amazonaws.com/doc/2009-01-01/"><SubmitFeedResult><FeedSubmissionInfo><FeedSubmissionId>8253017998</FeedSubmissionId><FeedType>_POST_ORDER_FULFILLMENT_DATA_</FeedType><SubmittedDate>2013-10-22T19:57:09+00:00</SubmittedDate><FeedProcessingStatus>_SUBMITTED_</FeedProcessingStatus></FeedSubmissionInfo></SubmitFeedResult><ResponseMetadata><RequestId>5d9a8cbb-aba4-4df7-b89c-8851114caa8d</RequestId></ResponseMetadata></SubmitFeedResponse>'
    end

    def successful_result
      '<AmazonEnvelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="amzn-envelope.xsd">
        <Header>
          <DocumentVersion>1.02</DocumentVersion>
          <MerchantIdentifier>M_WESKETCHUM_1357503</MerchantIdentifier>
        </Header>
        <MessageType>ProcessingReport</MessageType>
        <Message>
          <MessageID>1</MessageID>
          <ProcessingReport>
            <DocumentTransactionID>8253017998</DocumentTransactionID>
            <StatusCode>Complete</StatusCode>
            <ProcessingSummary>
              <MessagesProcessed>1</MessagesProcessed>
              <MessagesSuccessful>1</MessagesSuccessful>
              <MessagesWithError>0</MessagesWithError>
              <MessagesWithWarning>0</MessagesWithWarning>
            </ProcessingSummary>
          </ProcessingReport>
        </Message>
    </AmazonEnvelope>'
    end

    def submission_error
      '<ErrorResponse xmlns="https://mws.amazonservices.com/">
        <Error>
          <Type>Sender</Type>
          <Code>InvalidParameterValue</Code>
          <Message>Invalid query string provided - AWSAccessKeyId123=&amp;Action=SubmitFeed&amp;FeedType=_POST_ORDER_FULFILLMENT_DATA_&amp;SellerId=12344&amp;Signature=hV2s4TYWPnj4eJbDynEQ399KZlgpnM2K3udPrpm9F5o=&amp;SignatureMethod=HmacSHA256&amp;SignatureVersion=2&amp;Timestamp=2013-10-22T11:15:40-04:00&amp;Version=2009-01-01 is not valid; the value of a query string parameter may not contain a &apos;=&apos; delimiter</Message>
        </Error>
        <RequestID>53466fee-9497-4ca0-884f-4281475962a0</RequestID>
      </ErrorResponse>'
    end

    def status_error
      '<?xml version="1.0" encoding="UTF-8"?>
      <AmazonEnvelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="amzn-envelope.xsd">
      <Header>
        <DocumentVersion>1.02</DocumentVersion>
        <MerchantIdentifier>M_WESKETCHUM_1357503</MerchantIdentifier>
      </Header>
      <MessageType>ProcessingReport</MessageType>
      <Message>
        <MessageID>1</MessageID>
        <ProcessingReport>
        <DocumentTransactionID>8252984128</DocumentTransactionID>
        <StatusCode>Complete</StatusCode>
        <ProcessingSummary>
        <MessagesProcessed>1</MessagesProcessed>
        <MessagesSuccessful>0</MessagesSuccessful>
        <MessagesWithError>1</MessagesWithError>
        <MessagesWithWarning>0</MessagesWithWarning>
        </ProcessingSummary>
        <Result>
        <MessageID>1</MessageID>
        <ResultCode>Error</ResultCode>
        <ResultMessageCode>18021</ResultMessageCode>
        <ResultDescription>The quantities you provided for order id (103-6652650-4045858) were larger than the quantities that could be fulfilled. Please review the quantity from the order report and take into account any items that have been cancelled or already fulfilled.
        </ResultDescription>
        <AdditionalInfo>
        <AmazonOrderID>103-6652650-4045858</AmazonOrderID>
        </AdditionalInfo>
        </Result>
        </ProcessingReport>
        </Message>
        </AmazonEnvelope>'
    end
  end
end
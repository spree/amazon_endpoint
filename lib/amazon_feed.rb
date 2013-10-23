class AmazonFeed

  def initialize(config)
    @access_key = config['amazon.aws_access_key']
    @secret_key = config['amazon.secret_key']
    @seller_id = config['amazon.seller_id']
    @timestamp = Time.now
  end

  def submit(type, doc)
    @action = 'SubmitFeed'
    @feed_type = type

    res = HTTParty.post(request_uri, request_params(type, doc))
    feed_id = Feeds::Parser.parse_submission(res)
    status_message(feed_id)
  end

  private

  def signature
    digest = OpenSSL::Digest::Digest.new('sha256')
    Base64.encode64(OpenSSL::HMAC.digest(digest, @secret_key, canonical)).strip
  end


  def canonical
    ['POST', "mws.amazonservices.com", "/", build_query].join("\n")
  end

  def request_uri
    "https://mws.amazonservices.com/?" << build_query(signature)
  end

  def build_query(signature=nil)
    query = {
      "AWSAccessKeyId" => @access_key,
      "Action" => @action,
      "SellerId" => @seller_id,
      "SignatureMethod" => 'HmacSHA256',
      "SignatureVersion" => '2',
      "Timestamp" => @timestamp,
      "Version" => "2009-01-01"
    }

    query["Signature"] = signature if signature
    query["FeedType"] = @feed_type if @feed_type
    # Sort hash in natural-byte order
    Hash[Helpers.escape_date_time_params(query).sort].to_query
  end

  def request_params(type, doc)
    {
      format: "xml",
      headers: { "Content-MD5" => Digest::MD5.base64digest(doc)},
      body: doc
    }
  end

  def status_message(id)
    {
      messages: [
        message: 'amazon:feed:status',
        payload: {
          feed_id: id
        }
      ]
    }
  end

  module Helpers
    def self.escape_date_time_params(params={})
      params.map do |key, value|
        case value.class.name
        when "Time", "Date", "DateTime"
          {key => value.iso8601}
        when "Hash"
          {key => escape_date_time_params(value)}
        else
          {key => value}
        end
      end.reduce({}, :merge)
    end
  end
end
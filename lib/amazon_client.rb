class AmazonClient
  attr_accessor :client

  def initialize(creds)
    @client = MWS.new(creds)
  end

  def get_orders(created_after)
    @client.orders.list_orders(created_after: created_after)
  end

  def get_line_items()
  end
end
class Builder

  def initialize(orders)
    @orders = orders
  end

  def build_response
    if @orders.empty?
      response = nil
    else
      response = { messages: [] }
      @orders.each { |order| response[:messages] << order.to_h }
      response
    end
  end
end
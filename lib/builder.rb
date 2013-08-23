class Builder
  def initialize(orders)
    @orders = orders
  end

  def build_response(response={})
    return nil if @orders.empty?

    response[:messages] = @orders.collect &:to_message

    response
  end
end

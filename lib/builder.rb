class Builder
  def initialize(orders)
    @orders = orders
  end

  def build_response
    return nil if @orders.empty?

    response = { parameters: [{ name: 'amazon.last_updated_after',
                                value: @orders.last.last_update_date }] }

    response[:messages] = @orders.map &:to_message

    response
  end
end

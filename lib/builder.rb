class Builder

  def initialize(orders)
    @orders = orders
    @response = nil
  end

  def build_response
    if @orders.empty?
      @response
    else
      @response = { messages: [],
        parameters: [{ name: 'last_updated_after', value: @orders.last.last_update_date }] }

      @orders.each { |order| @response[:messages] << order.to_message }
    end

    @response
  end
end
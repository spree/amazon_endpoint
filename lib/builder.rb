class Builder
  def initialize(collection)
    @collection = collection.is_a?(Array) ? collection : [collection]
  end

  def build_response(response = {})
    return nil if @collection.empty?

    response[:messages] = @collection.collect(&:to_message)

    response
  end
end


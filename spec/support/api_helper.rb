module ApiHelper
  include Rack::Test::Methods

  def json_response
    JSON.parse(last_response.body)
  end
end


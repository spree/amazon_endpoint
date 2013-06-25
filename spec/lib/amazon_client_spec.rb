require 'spec_helper'

desrcibe AmazonClient do
  subject { AmazonClient.new({aws_access_key_id: 'AKIAIR24VLFSLJRUCXBQ', secret_access_key: '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',
              seller_id: 'A6WWS5LKYVEJ8', marketplace_id: 'ATVPDKIKX0DER')} }

  it 'gets amazon orders' do
    VCR.use_cassette('amazon_client_valid_orders') do
      
    end
  end
end
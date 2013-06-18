require 'spec_helper'

describe Item do

  let(:order) { Factories.orders.first }

  subject { order.line_items.first }

  it 'should convert into a hash' do
    item_hash = subject.to_h
    item_hash.class.should eq Hash
    item_hash[:sku].should eq "G9-LTWP-D1LD"
  end

  # See comment on convert_tommy_john_sku
  it 'converts tommy john skus' do
    amazon_sku = '2001SS-BL-L'
    spree_sku = subject.send(:convert_tommy_john_sku, amazon_sku)
    spree_sku.should eq '2001SSBL'
  end

  describe '#unit_price' do
    its(:unit_price) { should be 3.0 }
  end
end


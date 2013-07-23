require 'spec_helper'

describe Item do

  let(:order) { Factories.orders.first }

  subject { order.line_items.first }

  it 'should convert into a hash' do
    item_hash = subject.to_h
    item_hash.class.should eq Hash
    item_hash['sku'].should eq "G9-LTWP-D1LD"
  end
end

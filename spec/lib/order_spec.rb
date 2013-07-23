require 'spec_helper'

describe Order do

  subject { (Factories.orders.first) }

  it 'converts an order into a message' do
    message = subject.to_message
    message.class.should eq Hash
    message[:message].should eq "order:new"
  end

  it 'builds array of item hashes' do
    subject.line_items << Item.new(Factories.item_responses[1])
    items_hash = subject.to_message[:payload][:order][:line_items]
    items_hash.count.should eq 2
  end
end
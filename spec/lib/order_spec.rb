require 'spec_helper'

describe Order do

  subject { (Factories.orders.first) }

  it 'converts an order into a message' do
    message = subject.to_message
    message.class.should eq Hash
    message[:message].should eq "order:new"
  end

  it 'builds item hashes' do
    items_hash = subject.assemble_line_items
    binding.pry
  end
end
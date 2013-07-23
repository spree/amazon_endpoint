require 'spec_helper'

describe Builder do

  let(:orders) { Factories.orders }

  subject { Builder.new(orders) }

  it 'should build a response' do
    response = subject.build_response
    response[:messages].size.should eq 2
  end
end
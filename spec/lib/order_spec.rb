require 'spec_helper'

describe Order do
  subject { Factories.orders.first }

  describe '#to_message' do
    it 'converts an order into a message' do
      message = subject.to_message
      message.class.should eq Hash
      message[:message].should eq "order:import"
    end

    it 'builds array of item hashes' do
      subject.line_items << Item.new(Factories.item_responses[1])
      items_hash = subject.to_message[:payload][:order][:line_items]
      items_hash.count.should eq 2
    end

    it 'converts amazon state to spree state' do
      expect(subject.to_message[:payload][:order][:shipping_address][:state]).to eq 'Maryland'
    end

    context 'when lookup parameters is absent' do
      it 'returns shipping method from amazon' do
        expect(subject.to_message[:payload][:order][:shipments].
               first[:shipping_method]).to eq 'Standard'
      end
    end

    context 'when lookup parameters is present' do
      let(:shipping_us_express)  { 'US 2 DAY EXPRESS' }
      let(:parameters) { { 'amazon.shipping_method_lookup' => [{ 'standard' => shipping_us_express }] } }
      subject { Factories.orders(parameters).first }

      it 'returns shipping method from lookup parameters' do
        expect(subject.to_message[:payload][:order][:shipments].
               first[:shipping_method]).to eq shipping_us_express
      end
    end
  end
end

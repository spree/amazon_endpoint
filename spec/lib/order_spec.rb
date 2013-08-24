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

    describe '#shipping_address_names' do
      it 'sets firstname and lastname properly' do
        expect(subject.to_message[:payload][:order][:shipping_address][:firstname]).
          to eq 'Wesley'
        expect(subject.to_message[:payload][:order][:shipping_address][:lastname]).
          to eq 'Scott Ketchum'
     end
    end

    describe '#shipping_addresses' do
      context 'when address1 is absent' do
        context 'and address2 is present' do
          subject { Factories.orders.last }

          it 'promotes address2 to address1' do
            expect(subject.to_message[:payload][:order][:shipping_address][:address1]).
              to eq '19944 SPURRIER AVE'
            expect(subject.to_message[:payload][:order][:shipping_address][:address2]).
              to be_empty
          end
        end
      end
    end

    describe '#assemble_address' do
      it 'sets address1' do
        expect(subject.to_message[:payload][:order][:shipping_address][:address1]).
          to eq '19944 SPURRIER AVE'
      end
      it 'sets address2' do
        expect(subject.to_message[:payload][:order][:shipping_address][:address2]).
          to eq 'APTO 1'
      end

      context 'when address2 is abset' do
        subject { Factories.orders.last }
        it 'uses blank address2' do
          expect(subject.to_message[:payload][:order][:shipping_address][:address2]).
            to be_empty
        end
      end
    end

    describe '#order_phone_number' do
      it 'uses amazon response phone number' do
        expect(subject.to_message[:payload][:order][:shipping_address][:phone]).
          to eq '2409971905'
      end

      context 'when phone number is absent' do
        subject { Factories.orders.last }
        it 'uses a placeholder' do
          expect(subject.to_message[:payload][:order][:shipping_address][:phone]).
            to eq '000-000-0000'
        end
      end
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

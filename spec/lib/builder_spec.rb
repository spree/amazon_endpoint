require 'spec_helper'

describe Builder do
  let(:orders) { Factories.orders }

  subject { Builder.new orders }

  describe '#build_response' do
    context 'with orders' do
      it 'builds a response' do
        response = subject.build_response
        expect(response[:messages]).to have(2).items
      end
    end

    context 'without orders' do
      subject { Builder.new [] }

      it 'returns nil' do
        response = subject.build_response
        expect(response).to be_nil
      end
    end
  end
end
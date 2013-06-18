require 'spec_helper'

describe Builder do
  let(:collection) { Factories.orders }

  subject { Builder.new(collection) }

  describe '#build_response' do
    it 'builds a response' do
      response = subject.build_response
      expect(response[:messages]).to have(2).items
    end

    context 'when collection is empty' do
      subject { Builder.new [] }

      it 'returns nil' do
        response = subject.build_response
        expect(response).to be_nil
      end
    end
  end
end

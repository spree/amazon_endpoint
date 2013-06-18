require 'spec_helper'

module Feeds
  describe InventoryAvailabitity do
    subject { InventoryAvailabitity.new(Factories.item, '123') }

    describe '#to_xml' do
      it 'converts to xml' do
        expect(subject.to_xml).to include('<?xml version="1.0"?>')
      end

      it 'returns the feed_type' do
        expect(subject.feed_type).to eq '_POST_INVENTORY_AVAILABILITY_DATA_'
      end
    end
  end
end

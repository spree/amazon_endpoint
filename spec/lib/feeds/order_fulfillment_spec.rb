require 'spec_helper'

module Feeds
  describe OrderFulfillment do

    describe '#to_xml' do
      it 'converts to xml' do
        xml = OrderFulfillment.new(Factories.shipment, '123').to_xml
        expect(xml).to include('<?xml version="1.0"?>')
      end
    end
  end
end
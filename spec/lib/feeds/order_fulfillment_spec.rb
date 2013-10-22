require 'spec_helper'

module Feeds
  describe OrderFulfillment do

    context '#to_xml' do
      it 'should convert to xml' do
        xml = OrderFulfillment.new(Factories.shipment, '123').to_xml
        xml.include?('<?xml version="1.0"?>').should == true
      end
    end
  end
end
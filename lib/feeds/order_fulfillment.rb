module Feeds
  class OrderFulfillment

    def initialize(shipment, id)
      @merchant_id = id
      @shipment = shipment
    end

    def to_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.AmazonEnvelope {
          xml.Header {
            xml.DocumentVersion 1.01
            xml.MerchantIdentifier @merchant_id
          }
          xml.MessageType 'OrderFulfillment'
          xml.PurgeAndReplace 'false'
          xml.Message {
            xml.MessageID 1
            xml.OperationType 'Update'
            xml.OrderFulfillment {
              xml.AmazonOrderID @shipment['order_number']
              xml.MerchantFulfillmentID @shipment['order_number'].gsub(/\D/, '')
              xml.FulfillmentDate Time.now.strftime('%Y-%m-%dT%H:%M:%S')
              xml.FulfillmentData  {
                xml.CarrierName @shipment['shipping_method']
                xml.ShippingMethod @shipment['shipping_method']
                xml.ShipperTrackingNumber @shipment['tracking']
              }
              @shipment['items'].each do |item|
                xml.Item {
                  xml.AmazonOrderItemCode item['sku']
                  xml.MerchantFulfillmentItemID item['sku']
                  xml.Quantity item['quantity']
                }
              end
            }
          }
        }
      end

      builder.to_xml
    end
  end
end
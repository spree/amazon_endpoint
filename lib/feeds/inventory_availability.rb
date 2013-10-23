module Feeds
  class InventoryAvailabitity

    def initialize(item, id)
      @merchant_id = id
      @item        = item
    end

    def to_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.AmazonEnvelope {
          xml.Header {
            xml.DocumentVersion 1.01
            xml.MerchantIdentifier @merchant_id
          }
          xml.MessageType 'Inventory'
          xml.Message {
            xml.MessageID 1
            xml.OperationType 'Update'
            xml.Inventory {
              xml.SKU @item['sku']
              xml.Quantity @item['quantity']
            }
          }
        }
      end

      builder.to_xml
    end

    def feed_type
      '_POST_INVENTORY_AVAILABILITY_DATA_'
    end
  end
end

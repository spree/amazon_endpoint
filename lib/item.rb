class Item
  attr_accessor :shipping_price, :item_price, :item_tax, :promotion_discount,
                :shipping_discount, :gift_wrap, :gift_wrap_tax, :price

  def initialize(item_hash)
    @name               = item_hash['title']
    @quantity           = item_hash['quantity_ordered'].to_i
    @quantity_shipped   = item_hash['quantity_shipped']
    # TODO Make it generic - Hack for Tommy John
    @sku                = convert_tommy_john_sku item_hash['seller_sku']
    # Optional attributes
    #
    @item_price         = item_hash.fetch('item_price',         {})['amount'].to_f
    @item_tax           = item_hash.fetch('item_tax',           {})['amount'].to_f
    @promotion_discount = item_hash.fetch('promotion_discount', {})['amount'].to_f
    @price              = item_hash.fetch('item_price',         {})['amount'].to_f
    @shipping_price     = item_hash.fetch('shipping_price',     {})['amount'].to_f
    @shipping_discount  = item_hash.fetch('shipping_discount',  {})['amount'].to_f
    @gift_wrap          = item_hash.fetch('gift_wrap_price',    {})['amount'].to_f
    @gift_wrap_tax      = item_hash.fetch('gift_wrap_tax',      {})['amount'].to_f
  end

  def to_h
    { name: @name, price: @price, sku: @sku, quantity: @quantity, variant_id: nil, external_ref: nil,
      options: {} }
  end

  private

  # There is a mismatch between Amazon SKU's and Tommy John Spree SKU's
  # 2001SS-BL-L should be converted to 2001SSBL
  # this is a temporary fix to get production working Aug 13, 2013
  def convert_tommy_john_sku(sku)
    if sku =~ /\w-\w{2}-\w/
      parts = sku.split('-')
      sku = "#{parts[0]}#{parts[1][0]}#{parts[2]}"
    end
    sku
  end
end

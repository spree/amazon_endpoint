class Order
  attr_accessor :line_items, :last_update_date

  def initialize(order_hash, config)
    @line_items         = []
    @order_hash         = order_hash
    @config             = config
    @order_total        = order_hash['order_total']['amount'].to_f
    @last_update_date   = order_hash['last_update_date']
    @status             = order_hash['order_status']
    @shipping_total     = 0.00
    @shipping_discount  = 0.00
    @promotion_discount = 0.00
    @amazon_tax         = 0.00
    @gift_wrap          = 0.00
    @gift_wrap_tax      = 0.00
    @items_total        = 0.00
  end

  def to_message
    roll_up_item_values
    items_hash       = assemble_line_items
    address_hash     = assemble_address
    totals_hash      = assemble_totals_hash
    adjustments_hash = assemble_adjustments_hash
    shipment_hash    = assemble_shipment_hash(items_hash)

    { message: 'order:import',
      payload:
      { order:
        { number: @order_hash['amazon_order_id'],
          channel: @order_hash['sales_channel'],
          currency: @order_hash['order_total']['currency_code'],
          status: @order_hash['order_status'],
          placed_on: @order_hash['purchase_date'],
          updated_at: @order_hash['last_update_date'],
          email: @order_hash['buyer_email'],
          totals: totals_hash,
          adjustments: adjustments_hash,
          line_items: items_hash,
          payments: [{
            amount: @order_total,
            payment_method: 'Amazon',
            status: 'complete'
          }],
          shipments: shipment_hash,
          shipping_address: address_hash,
          billing_address: address_hash } } }
  end

  private

  def assemble_line_items
    @line_items.collect &:to_h
  end

  def assemble_address
    # Sometimes Amazon can respond with null address1. It is invalid for the integrator
    # The property '#/order/shipping_address/address1' of type NilClass did not match the following type:
    # string in schema augury/lib/augury/validators/schemas/address.json#
    # ['shipping_address']['address_line1'].to_s
    # "shipping_address": {
    #   "address1": null
    #
    # @order_hash['buyer_name'].to_s buyer_name can be nil as well
    firstname, lastname = shipping_address_names
    address1,  address2 = shipping_addresses

    { firstname:  firstname,
      lastname:   lastname,
      address1:   address1.to_s,
      address2:   address2.to_s,
      city:       @order_hash['shipping_address']['city'],
      zipcode:    @order_hash['shipping_address']['postal_code'],
      phone:      order_phone_number,
      country:    @order_hash['shipping_address']['country_code'],
      state:      order_full_state }
  end

  def shipping_address_names
    names = @order_hash['shipping_address']['name'].to_s.split(' ')
    # Pablo Henrique Sirio Tejero Cantero
    # => ["Pablo", "Henrique Sirio Tejero Cantero"]
    [names.first.to_s,            # Pablo
     names[1..-1].to_a.join(' ')] # Henrique Sirio Tejero Cantero
  end

  def shipping_addresses
    # Promotes address2 to address1 when address1 is absent.
    [
      @order_hash['shipping_address']['address_line1'],
      @order_hash['shipping_address']['address_line2'],
      @order_hash['shipping_address']['address_line3']
    ].
      compact.
      reject { |address| address.empty? }
  end

  def order_phone_number
    # https://basecamp.com/1795324/projects/3492877-tommy-john/messages/14737577-amazon-orders#comment_86881056
    phone_number = @order_hash['shipping_address']['phone'].to_s.strip
    if phone_number.empty?
      return '000-000-0000'
    end
    phone_number
  end

  def roll_up_item_values
    @line_items.each do |item|
      @shipping_total     += item.shipping_price
      @shipping_discount  += item.shipping_discount
      @promotion_discount += item.promotion_discount
      @amazon_tax         += item.item_tax
      @gift_wrap          += item.gift_wrap
      @gift_wrap_tax      += item.gift_wrap_tax
      @items_total        += item.total_price
    end
  end

  def assemble_totals_hash
    { item: @items_total,
      adjustment: @promotion_discount + @shipping_discount + @gift_wrap + @amazon_tax + @gift_wrap_tax,
      tax: @amazon_tax + @gift_wrap_tax,
      shipping: @shipping_total,
      order:  @order_total,
      payment: @order_total }
  end

  def assemble_adjustments_hash
    [{ name: 'Shipping Discount', value: @shipping_discount },
     { name: 'Promotion Discount', value: @promotion_discount },
     { name: 'Amazon Tax', value: @amazon_tax },
     { name: 'Gift Wrap Price', value: @gift_wrap },
     { name: 'Gift Wrap Tax', value: @gift_wrap_tax }]
  end

  def assemble_shipment_hash(line_items)
    [{ cost: @shipping_total,
       status: @status,
       shipping_method: order_shipping_method,
       items: line_items,
       stock_location: '',
       tracking: '',
       number: '' }]
  end

  def order_shipping_method
    amazon_shipping_method = @order_hash['shipment_service_level_category']
    amazon_shipping_method_lookup.each do |shipping_method, value|
      return value if shipping_method.downcase == amazon_shipping_method.downcase
    end
    amazon_shipping_method
  end

  def amazon_shipping_method_lookup
    @config['amazon.shipping_method_lookup'].to_a.first.to_h
  end

  def order_full_state
    states_hash[@order_hash['shipping_address']['state_or_region'].upcase] ||
      @order_hash['shipping_address']['state_or_region']
  end

  def states_hash
    { 'AL' => 'Alabama',
      'AK' => 'Alaska',
      'AZ' => 'Arizona',
      'AR' => 'Arkansas',
      'CA' => 'California',
      'CO' => 'Colorado',
      'CT' => 'Connecticut',
      'DC' => 'District of Columbia',
      'DE' => 'Delaware',
      'FL' => 'Florida',
      'GA' => 'Georgia',
      'HI' => 'Hawaii',
      'ID' => 'Idaho',
      'IL' => 'Illinois',
      'IN' => 'Indiana',
      'IA' => 'Iowa',
      'KS' => 'Kansas',
      'KY' => 'Kentucky',
      'LA' => 'Louisiana',
      'ME' => 'Maine',
      'MD' => 'Maryland',
      'MA' => 'Massachusetts',
      'MI' => 'Michigan',
      'MN' => 'Minnesota',
      'MS' => 'Mississippi',
      'MO' => 'Missouri',
      'MT' => 'Montana',
      'NE' => 'Nebraska',
      'NV' => 'Nevada',
      'NH' => 'New Hampshire',
      'NJ' => 'New Jersey',
      'NM' => 'New Mexico',
      'NY' => 'New York',
      'NC' => 'North Carolina',
      'ND' => 'North Dakota',
      'OH' => 'Ohio',
      'OK' => 'Oklahoma',
      'OR' => 'Oregon',
      'PA' => 'Pennsylvania',
      'RI' => 'Rhode Island',
      'SC' => 'South Carolina',
      'SD' => 'South Dakota',
      'TN' => 'Tennessee',
      'TX' => 'Texas',
      'UT' => 'Utah',
      'VT' => 'Vermont',
      'VA' => 'Virginia',
      'WA' => 'Washington',
      'WV' => 'West Virginia',
      'WI' => 'Wisconsin',
      'WY' => 'Wyoming',
      'AA' => 'U.S. Armed Forces – Americas',
      'AE' => 'U.S. Armed Forces – Europe',
      'AP' => 'U.S. Armed Forces – Pacific' }
  end
end

module Factories
  class << self

    def orders(config={})
      order1 = Order.new(order_responses[0], config)
      order2 = Order.new(order_responses[1], config)
      order1.line_items << Item.new(item_responses[0])
      order2.line_items << Item.new(item_responses[1])
      [order1, order2]
    end

    def order_responses
      [{ "shipment_service_level_category"=>"Standard",
        "order_total"=>{"amount"=>"8.79", "currency_code"=>"USD"},
        "ship_service_level"=>"Std Cont US Street Addr",
        "marketplace_id"=>"ATVPDKIKX0DER",
        "shipping_address"=>
          {"phone"=>"2409971905",
           "postal_code"=>"20837-3004",
           "name"=>"Wesley Scott Ketchum",
           "country_code"=>"US",
           "state_or_region"=>"MD",
           "address_line1"=>"19944 SPURRIER AVE",
           "address_line2"=>"APTO 1",
           "city"=>"POOLESVILLE"},
           "sales_channel"=>"Amazon.com",
        "shipped_by_amazon_tfm"=>"false",
        "order_type"=>"StandardOrder",
        "buyer_email"=>"knsrqr1h8bkp9yh@marketplace.amazon.com",
        "fulfillment_channel"=>"MFN",
        "order_status"=>"Shipped",
        "buyer_name"=>"wes ketchum",
        "last_update_date"=>"2013-06-17T21:41:33Z",
        "purchase_date"=>"2013-06-17T20:12:54Z",
        "number_of_items_unshipped"=>"0",
        "number_of_items_shipped"=>"5",
        "amazon_order_id"=>"111-6494089-5358640",
        "payment_method"=>"Other" },
        {"shipment_service_level_category"=>"Standard",
         "order_total"=>{"amount"=>"16.19", "currency_code"=>"USD"},
         "ship_service_level"=>"Std Cont US Street Addr",
         "marketplace_id"=>"ATVPDKIKX0DER",
         "shipping_address"=>
          {"postal_code"=>"20837-3004",
           "name"=>"Wesley Scott Ketchum",
           "country_code"=>"US",
           "state_or_region"=>"MD",
           "address_line2"=>"19944 SPURRIER AVE",
           "city"=>"POOLESVILLE"},
         "sales_channel"=>"Amazon.com",
         "shipped_by_amazon_tfm"=>"false",
         "order_type"=>"StandardOrder",
         "buyer_email"=>"knsrqr1h8bkp9yh@marketplace.amazon.com",
         "fulfillment_channel"=>"MFN",
         "order_status"=>"Unshipped",
         "buyer_name"=>"wes ketchum",
         "last_update_date"=>"2013-06-19T17:45:49Z",
         "purchase_date"=>"2013-06-19T17:15:29Z",
         "number_of_items_unshipped"=>"2",
         "number_of_items_shipped"=>"0",
         "amazon_order_id"=>"111-2374817-1293015",
         "payment_method"=>"Other"} ]
    end

    def item_responses
     [{ "order_item_id"=>"58145946945682",
         "gift_wrap_price"=>{"amount"=>"0.00", "currency_code"=>"USD"},
         "quantity_ordered"=>"3",
         "gift_wrap_tax"=>{"amount"=>"0.00", "currency_code"=>"USD"},
         "seller_sku"=>"G9-LTWP-D1LD",
         "title"=>"Zak Designs Ella Individual Bowls, Orange, Set of 6",
         "shipping_tax"=>{"amount"=>"0.00", "currency_code"=>"USD"},
         "shipping_price"=>{"amount"=>"5.69", "currency_code"=>"USD"},
         "item_tax"=>{"amount"=>"0.00", "currency_code"=>"USD"},
         "item_price"=>{"amount"=>"9.00", "currency_code"=>"USD"},
         "promotion_discount"=>{"amount"=>"0.00", "currency_code"=>"USD"},
         "asin"=>"B005PY90JS",
         "condition_id"=>"Used",
         "quantity_shipped"=>"3",
         "condition_subtype_id"=>"Mint",
         "shipping_discount"=>{"amount"=>"0.00", "currency_code"=>"USD"}},
       {"order_item_id"=>"01029183238402",
       "gift_wrap_price"=>{"amount"=>"0.00", "currency_code"=>"USD"},
       "quantity_ordered"=>"1",
       "gift_wrap_tax"=>{"amount"=>"0.00", "currency_code"=>"USD"},
       "seller_sku"=>"SV-Q5JI-31JT",
       "title"=>
        "10 Strawberry Street Catering Set 10-1/2-Inch Dinner Plate, Set of 12",
       "shipping_tax"=>{"amount"=>"0.00", "currency_code"=>"USD"},
       "shipping_price"=>{"amount"=>"13.75", "currency_code"=>"USD"},
       "item_tax"=>{"amount"=>"0.00", "currency_code"=>"USD"},
       "item_price"=>{"amount"=>"9.00", "currency_code"=>"USD"},
       "promotion_discount"=>{"amount"=>"0.00", "currency_code"=>"USD"},
       "asin"=>"B002LAAFYS",
       "condition_id"=>"Refurbished",
       "quantity_shipped"=>"0",
       "condition_subtype_id"=>"Refurbished",
       "shipping_discount"=>{"amount"=>"0.00", "currency_code"=>"USD"}}]
    end

    def shipment
      {
          "number" => "H03606064322",
          "order_number" => "103-6652650-4045858",
          "email" => "spree@example.com",
          "cost" => 0.0,
          "status" => "ready",
          "stock_location" => nil,
          "shipping_method" => "Economy (5-10 Business Days - $0.00)",
          "tracking" => "915293072790129",
          "updated_at" => nil,
          "shipped_at" => nil,
          "shipping_address"=> {
          "firstname"=> "Brian",
          "lastname"=> "Quinn",
          "address1"=> "2 Wisconsin Cir.",
          "address2"=> "",
          "zipcode"=> "20815",
          "city"=> "Chevy Chase",
          "state"=> "Maryland",
          "country"=> "US",
          "phone"=> "555-123-123"
          },
          "items" => [
            {
              "name" => "test",
              "sku" => "27368845791002",
              "external_ref" => "",
              "quantity" => 2,
              "price" => 1.25,
              "variant_id" => 2,
              "options" => {
              }
            }
          ]
      }
    end
  end
end
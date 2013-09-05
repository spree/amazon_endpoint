# Amazon Endpoint

For a detailted explanation check out the [Spree Guides - Amazon Endpoint](http://guides.spreecommerce.com/integration/amazon_integration.html).

## Return Orders

* Receives an amazon:order:poll message and looks for new orders in Amazon
* Returns orders to be imported into Spree

## Return Specific Order

* Receives an amazon:import:by_number message and looks for a specific order in Amazon
* Returns a specific order from Amazon filtered by `amazon_order_id` to be imported into Spree

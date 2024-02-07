class EtsyService
  SHOP_ID = ENV['ETSY_SHOP_ID']

  class << self
    def import_order(receipt_id:, access_token:)
      response = RestClient.get("https://openapi.etsy.com/v3/application/shops/#{SHOP_ID}/receipts/#{receipt_id}",
        {
          'x-api-key': ENV['ETSY_API_KEY'],
          'Authorization': "Bearer #{access_token}"
        }
      )

      if response.code == 200      
        response = JSON.parse(response.body)
      end

      order = Order.new(
        is_etsy_imported: true,
        order_status: :onhold,
        order_edit_status: :incomplete,
        etsy_order_id: response['receipt_id'],
        note_to_buyer: response['message_from_seller'],
        note_to_seller: response['message_from_buyer'],
        customer_name: response['name'],
        grandtotal_json: response['grandtotal'],
        subtotal_json: response['subtotal'],
        total_price_json: response['total_price'],
        total_shipping_cost_json: response['total_shipping_cost'],
        total_tax_cost_json: response['total_tax_cost'],
        total_vat_cost_json: response['total_vat_cost'],
        discount_amt_json: response['discount_amt'],
        gift_wrap_price_json: response['gift_wrap_price'],
        shipments_json: response['shipments'],
        transactions_json: response['transactions'],
        refunds_json: response['refunds']
      )

      order.build_address(
        fullname: response['name'],
        country: response['country_iso'],
        state: response['state'],
        address1: response['first_line'],
        address2: response['second_line'],
        city: response['city'],
        zipcode: response['zip'],
        email: response['buyer_email']
      )

      order.save
    end

    # def dummy_response
    #   {
    #     "receipt_id": 1,
    #     "receipt_type": 0,
    #     "seller_user_id": 1,
    #     "seller_email": "user@example.com",
    #     "buyer_user_id": 1,
    #     "buyer_email": "string",
    #     "name": "string",
    #     "first_line": "string",
    #     "second_line": "string",
    #     "city": "string",
    #     "state": "string",
    #     "zip": "string",
    #     "status": "paid",
    #     "formatted_address": "string",
    #     "country_iso": "string",
    #     "payment_method": "string",
    #     "payment_email": "string",
    #     "message_from_seller": "string",
    #     "message_from_buyer": "string",
    #     "message_from_payment": "string",
    #     "is_paid": true,
    #     "is_shipped": true,
    #     "create_timestamp": 946684800,
    #     "created_timestamp": 946684800,
    #     "update_timestamp": 946684800,
    #     "updated_timestamp": 946684800,
    #     "is_gift": true,
    #     "gift_message": "string",
    #     "grandtotal": {
    #       "amount": 0,
    #       "divisor": 0,
    #       "currency_code": "string"
    #     },
    #     "subtotal": {
    #       "amount": 0,
    #       "divisor": 0,
    #       "currency_code": "string"
    #     },
    #     "total_price": {
    #       "amount": 0,
    #       "divisor": 0,
    #       "currency_code": "string"
    #     },
    #     "total_shipping_cost": {
    #       "amount": 0,
    #       "divisor": 0,
    #       "currency_code": "string"
    #     },
    #     "total_tax_cost": {
    #       "amount": 0,
    #       "divisor": 0,
    #       "currency_code": "string"
    #     },
    #     "total_vat_cost": {
    #       "amount": 0,
    #       "divisor": 0,
    #       "currency_code": "string"
    #     },
    #     "discount_amt": {
    #       "amount": 0,
    #       "divisor": 0,
    #       "currency_code": "string"
    #     },
    #     "gift_wrap_price": {
    #       "amount": 0,
    #       "divisor": 0,
    #       "currency_code": "string"
    #     },
    #     "shipments": [
    #       {
    #         "receipt_shipping_id": 1,
    #         "shipment_notification_timestamp": 946684800,
    #         "carrier_name": "string",
    #         "tracking_code": "string"
    #       }
    #     ],
    #     "transactions": [
    #       {
    #         "transaction_id": 1,
    #         "title": "string",
    #         "description": "string",
    #         "seller_user_id": 1,
    #         "buyer_user_id": 1,
    #         "create_timestamp": 946684800,
    #         "created_timestamp": 946684800,
    #         "paid_timestamp": 946684800,
    #         "shipped_timestamp": 946684800,
    #         "quantity": 0,
    #         "listing_image_id": 1,
    #         "receipt_id": 1,
    #         "is_digital": true,
    #         "file_data": "string",
    #         "listing_id": 0,
    #         "transaction_type": "string",
    #         "product_id": 1,
    #         "sku": "string",
    #         "price": {
    #           "amount": 0,
    #           "divisor": 0,
    #           "currency_code": "string"
    #         },
    #         "shipping_cost": {
    #           "amount": 0,
    #           "divisor": 0,
    #           "currency_code": "string"
    #         },
    #         "variations": [
    #           {
    #             "property_id": 0,
    #             "value_id": 0,
    #             "formatted_name": "string",
    #             "formatted_value": "string"
    #           }
    #         ],
    #         "product_data": [
    #           {
    #             "property_id": 1,
    #             "property_name": "string",
    #             "scale_id": 1,
    #             "scale_name": "string",
    #             "value_ids": [
    #               1
    #             ],
    #             "values": [
    #               "string"
    #             ]
    #           }
    #         ],
    #         "shipping_profile_id": 1,
    #         "min_processing_days": 1,
    #         "max_processing_days": 1,
    #         "shipping_method": "string",
    #         "shipping_upgrade": "string",
    #         "expected_ship_date": 946684800,
    #         "buyer_coupon": 0,
    #         "shop_coupon": 0
    #       }
    #     ],
    #     "refunds": [
    #       {
    #         "amount": {
    #           "amount": 0,
    #           "divisor": 0,
    #           "currency_code": "string"
    #         },
    #         "created_timestamp": 946684800,
    #         "reason": "string",
    #         "note_from_issuer": "string",
    #         "status": "string"
    #       }
    #     ]
    #   }.with_indifferent_access
    # end
  end
end

class MpesasController < ApplicationController
    
    require 'rest-client'
  
      def initialize
        super
        ActiveSupport::Notifications.subscribe('order.created') do |name, start, finish, id, payload|
          order = payload[:order]
          update_customer_phonenumber(order.customer_phonenumber)
        end
      end
  
  
      def callback
        request_body = request.body.read
        process_callback(request_body)
        render json: { status: 'success' }
      end   
    
      def stkpush
        phoneNumber = @phoneNumber
        amount = params[:amount]
        url = "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
        timestamp = "#{Time.now.strftime "%Y%m%d%H%M%S"}"
        business_short_code = ENV["MPESA_SHORTCODE"]
        password = Base64.strict_encode64("#{business_short_code}#{ENV["MPESA_PASSKEY"]}#{timestamp}")
        payload = {
        'BusinessShortCode': business_short_code,
        'Password': password,
        'Timestamp': timestamp,
        'TransactionType': "CustomerPayBillOnline",
        'Amount': amount,
        'PartyA': phoneNumber,
        'PartyB': business_short_code,
        'PhoneNumber': phoneNumber,
        'CallBackURL': "#{ENV["CALLBACK_URL"]}/callback",
        'AccountReference': 'Codearn',
        'TransactionDesc': "Payment for Codearn premium"
        }.to_json
  
        headers = {
        Content_type: 'application/json',
        Authorization: "Bearer #{get_access_token}"
        }
  
        response = RestClient::Request.new({
        method: :post,
        url: url,
        payload: payload,
        headers: headers
        }).execute do |response, request|
        case response.code
        when 500
        [ :error, JSON.parse(response.to_str) ]
        when 400
        [ :error, JSON.parse(response.to_str) ]
        when 200
        [ :success, JSON.parse(response.to_str) ]
        else
        fail "Invalid response #{response.to_str} received."
        end
        end
        render json: response
    end
  
    # stkquery
  
    def stkquery
        url = "https://sandbox.safaricom.co.ke/mpesa/stkpushquery/v1/query"
        timestamp = "#{Time.now.strftime "%Y%m%d%H%M%S"}"
        business_short_code = ENV["MPESA_SHORTCODE"]
        password = Base64.strict_encode64("#{business_short_code}#{ENV["MPESA_PASSKEY"]}#{timestamp}")
        payload = {
        'BusinessShortCode': business_short_code,
        'Password': password,
        'Timestamp': timestamp,
        'CheckoutRequestID': params[:checkoutRequestID]
        }.to_json
  
        headers = {
        Content_type: 'application/json',
        Authorization: "Bearer #{ get_access_token }"
        }
  
        response = RestClient::Request.new({
        method: :post,
        url: url,
        payload: payload,
        headers: headers
        }).execute do |response, request|
        case response.code
        when 500
        [ :error, JSON.parse(response.to_str) ]
        when 400
        [ :error, JSON.parse(response.to_str) ]
        when 200
        [ :success, JSON.parse(response.to_str) ]
        else
        fail "Invalid response #{response.to_str} received."
        end
        end
        render json: response
    end
  
    private
  
    def generate_access_token_request
        @url = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
        @consumer_key = ENV['MPESA_CONSUMER_KEY']
        @consumer_secret = ENV['MPESA_CONSUMER_SECRET']
        puts "Consumer Key: #{@consumer_key}"
        puts "Consumer Secret: #{@consumer_secret}"
        @userpass = Base64::strict_encode64("#{@consumer_key}:#{@consumer_secret}")
        puts "Encoded Userpass: #{@userpass}"
        headers = {
            Authorization: "Bearer #{@userpass}"
        }
        puts "Request Headers: #{headers}"
        res = RestClient::Request.execute( url: @url, method: :get, headers: {
            Authorization: "Basic #{@userpass}"
        })
        res
    end
  
    def get_access_token
        res = generate_access_token_request()
        if res.code != 200
        r = generate_access_token_request()
        if res.code != 200
        raise MpesaError('Unable to generate access token')
        end
        end
        body = JSON.parse(res, { symbolize_names: true })
        token = body[:access_token]
        AccessToken.destroy_all()
        AccessToken.create!(token: token)
        token
    end
  
    def update_customer_phonenumber(customer_phonenumber)    
      @phoneNumber = customer_phonenumber
    end
  
  
end
require 'rest-client'

class EtsyController < ApplicationController
  def authorize
    etsy_client = OAuth2::Client.new(
      ENV['ETSY_API_KEY'],
      ENV['ETSY_API_SECRET'],
      site: 'https://www.etsy.com',
      authorize_url: '/oauth/connect',
      token_url: '/v3/public/oauth/token',
      redirect_uri: 'https://1c42-122-161-50-131.ngrok-free.app/etsy/callback'
    )

    authorize_url = etsy_client.auth_code.authorize_url(
      scope: 'listings_r',
      state: 'superstate',
      code_challenge: ENV['ETSY_CODE_CHALLENGE'],
      code_challenge_method: 'S256'
    )

    redirect_to authorize_url, allow_other_host: true
  end

  def callback
    query_params = {
      grant_type: "authorization_code",
      client_id: ENV['ETSY_API_KEY'],
      redirect_uri: 'https://1c42-122-161-50-131.ngrok-free.app/etsy/callback',
      code: params[:code],
      code_verifier: ENV['ETSY_CODE_VERIFIER']
    }

    response = RestClient.post('https://api.etsy.com/v3/public/oauth/token', query_params)

    token = JSON.parse(response.body)

    current_user.update(etsy_access_token: token["access_token"], etsy_refresh_token: token["refresh_token"])

    RefreshAccessTokenJob.set(wait: (token["expires_in"] - 300).seconds).perform_later(user_id: current_user.id)

    redirect_to root_path
  end
end

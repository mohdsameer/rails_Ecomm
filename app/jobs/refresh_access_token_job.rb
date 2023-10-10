class RefreshAccessTokenJob < ApplicationJob
  def perform(user_id:)
    user = User.find(user_id)

    query_params = {
      grant_type: "refresh_token",
      client_id: ENV['ETSY_API_KEY'],
      refresh_token: user.etsy_refresh_token
    }

    response = RestClient.post('https://api.etsy.com/v3/public/oauth/token', query_params)

    token = JSON.parse(response.body)

    user.update(etsy_access_token: token["access_token"], etsy_refresh_token: token["refresh_token"])

    RefreshAccessTokenJob.set(wait: (token["expires_in"] - 300).seconds).perform_later(user_id: user.id)
  end
end

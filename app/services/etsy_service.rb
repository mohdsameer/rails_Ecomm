# require 'etsy'

# class EtsyService
#   def initialize
#     # Etsy.protocol   = 'https'
#     # Etsy.api_key    = 'd2dltlxiqk49e004gugboek1'
#     # Etsy.api_secret = 'rrnicft74k'

#     # request = Etsy.request_token
#     # Etsy.verification_url

#     # access = Etsy.access_token(request.token, request.secret, code.chomp)

#     Etsy.environment         = :sandbox
#     Etsy.api_key             = "d2dltlxiqk49e004gugboek1"
#     Etsy.api_secret          = "rrnicft74k"
#     Etsy.callback_url        = "http://localhost:3000/callbacks/etsy"
#     request                  = Etsy.request_token
#     session[:request_token]  = request.token
#     session[:request_secret] = request.secret

#     redirect_to Etsy.verification_url

#     request = Etsy.request_token
#   end
# end

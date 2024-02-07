# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  name                   :string
#  type                   :string
#  email                  :string           not null
#  password_digest        :string
#  company_name           :string
#  location               :string
#  black_price            :float
#  front_side_print_price :float
#  back_side_print_price  :float
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  etsy_access_token      :string
#  etsy_refresh_token     :string
#  pending_payment        :decimal(, )      default(0.0)
#  requested_payment      :decimal(, )      default(0.0)
#  received_payment       :decimal(, )      default(0.0)
#
class Admin < User
end

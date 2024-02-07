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
class Designer < User
  # Associations
  has_many :assign_details, foreign_key: :user_id
  has_many :orders, through: :assign_details

  # INSTANCE METHODS
  def no_of_orders_completed
    orders.completed.uniq.count
  end

  def total_earned
    (pending_payment.to_f + received_payment.to_f + requested_payment.to_f).round(2)
  end

  def has_requested_payment?
    requested_payment.to_f > 0
  end

  def has_pending_payment?
    pending_payment.to_f > 0
  end

  def request_payment
    if update(requested_payment: (requested_payment.to_f + pending_payment.to_f))
      update(pending_payment: 0.0)
    end
  end
end

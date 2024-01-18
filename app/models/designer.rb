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

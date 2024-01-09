class Payment < ApplicationRecord
  # ASSOCIATIONS
  belongs_to :receiver, foreign_key: :receiver_id, class_name: 'User'

  # CALLBACKS
  after_create :update_receiver_data

  # INSTANCE METHODS
  def update_receiver_data
    amount_diff      = receiver.requested_payment.to_f - amount.to_f
    pending_payment  = receiver.pending_payment.to_f + amount_diff.to_f
    received_payment = receiver.received_payment.to_f + amount.to_f

    receiver.update(pending_payment: pending_payment, received_payment: received_payment, requested_payment: 0.0)
  end
end

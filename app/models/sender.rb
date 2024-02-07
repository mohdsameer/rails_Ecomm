# == Schema Information
#
# Table name: senders
#
#  id         :bigint           not null, primary key
#  order_id   :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Sender < ApplicationRecord
  # Associations
  has_one :address, as: :addressable
end

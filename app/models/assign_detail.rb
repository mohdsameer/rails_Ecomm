# == Schema Information
#
# Table name: assign_details
#
#  id                 :bigint           not null, primary key
#  user_id            :bigint
#  order_id           :bigint
#  price_per_design   :decimal(, )
#  price_for_total    :decimal(, )
#  due_date           :datetime
#  additional_comment :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class AssignDetail < ApplicationRecord
  belongs_to :order
  belongs_to :designer, foreign_key: :user_id, class_name: "User"
end

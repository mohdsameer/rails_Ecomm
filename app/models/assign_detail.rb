class AssignDetail < ApplicationRecord
  belongs_to :order
  belongs_to :designer, foreign_key: :user_id, class_name: "User"
end

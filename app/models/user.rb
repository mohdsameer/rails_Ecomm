class User < ApplicationRecord
  has_secure_password

  # ASSOCIATIONS
  has_many :payments, foreign_key: :receiver_id, dependent: :destroy

  # VALIDATIONS
  validates :email, presence: true, uniqueness: true

  def admin?
    type == 'Admin'
  end

  def designer?
    type == 'Designer'
  end

  def producer?
    type == 'Producer'
  end
end

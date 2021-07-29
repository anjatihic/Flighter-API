# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  first_name      :string
#  last_name       :string
#  email           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :text             not null
#  token           :text
#  role            :string
#
class User < ApplicationRecord
  has_many :bookings, dependent: :nullify

  has_secure_password
  has_secure_token

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/

  validates :first_name, presence: true, length: { minimum: 2 }

  def admin?
    role == 'admin'
  end
end

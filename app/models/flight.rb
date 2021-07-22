# == Schema Information
#
# Table name: flights
#
#  id          :bigint           not null, primary key
#  name        :string
#  no_of_seats :integer
#  base_price  :integer
#  departs_at  :datetime
#  arrives_at  :datetime
#  company_id  :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Flight < ApplicationRecord
  belongs_to :company
  has_many :bookings, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :company_id, case_sensitive: false }

  validates :departs_at, presence: true
  validates :arrives_at, presence: true
  validate :departs_must_be_before_arrives

  validates :base_price, presence: true, numericality: { greater_than: 0 }

  def departs_must_be_before_arrives
    return unless departs_at && arrives_at

    errors.add(:departs_at, 'must be before arrival time') if departs_at > arrives_at
  end
end

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
  SECONDS_IN_A_DAY = 86_400

  belongs_to :company
  has_many :bookings, dependent: :nullify

  scope :name_cont, ->(word) { where('flights.name LIKE ?', "%#{word}%") }
  scope :departs_at_eq, ->(timestamp) { where("DATE_TRUNC('second', departs_at) = ?", timestamp) }
  scope :no_of_available_seats_gteq,
        ->(no_seats) { left_outer_joins(:bookings).having('flights.no_of_seats - SUM(bookings.no_of_seats) >= ?', no_seats).group('flights.id') } # rubocop:disable Layout/LineLength

  validates :name, presence: true, uniqueness: { scope: :company_id, case_sensitive: false }

  validates :departs_at, presence: true
  validates :arrives_at, presence: true
  validate :departs_must_be_before_arrives

  validate :aircraft_must_be_available

  validates :base_price, presence: true, numericality: { greater_than: 0 }

  validates :no_of_seats, presence: true, numericality: { greater_than: 0 }

  def departs_must_be_before_arrives
    return unless departs_at && arrives_at

    errors.add(:departs_at, 'must be before arrival time') if departs_at > arrives_at
  end

  def aircraft_must_be_available
    return unless departs_at && arrives_at

    needed_time = departs_at...arrives_at

    company.flights.each do |company_flight|
      next if id == company_flight.id

      busy_time = company_flight.departs_at...company_flight.arrives_at

      if busy_time.cover?(needed_time)
        errors.add(:departs_at, 'no available aircrafts')
        break
      end
    end
  end

  def no_of_booked_seats
    bookings.sum('no_of_seats')
  end

  def current_price
    days_left = (departs_at - Time.now.utc).div(SECONDS_IN_A_DAY)

    return base_price * 2 if days_left <= 0

    if days_left >= 15
      base_price
    else
      new_price = ((15 - days_left) / 15.00) * base_price + base_price
      new_price.round
    end
  end
end

# == Schema Information
#
# Table name: bookings
#
#  id          :bigint           not null, primary key
#  no_of_seats :integer
#  seat_price  :integer
#  user_id     :bigint
#  flight_id   :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :flight

  validates :seat_price, presence: true, numericality: { greater_than: 0 }

  validates :no_of_seats, presence: true, numericality: { greater_than: 0 }

  validate :flight_not_in_past

  validate :flight_not_overbooked

  def flight_not_in_past
    return unless flight

    errors.add(:flight, "can't be in the past") if flight.departs_at < DateTime.current
  end

  def flight_not_overbooked
    return unless flight

    seats_in_a_booking = Booking.find_by(id: id)&.no_of_seats
    seats_in_a_booking = 0 if seats_in_a_booking.nil?

    difference = no_of_seats - seats_in_a_booking
    return if difference.negative?

    errors.add(:no_of_seats, 'not enough available seats') if difference > flight.reload.free_seats
  end

  def total_price
    seat_price * no_of_seats
  end
end

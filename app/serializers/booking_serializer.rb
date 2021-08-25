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
class BookingSerializer < Blueprinter::Base
  identifier :id

  field :no_of_seats
  field :seat_price
  field :created_at
  field :updated_at
  field :total_price

  association :user, blueprint: UserSerializer
  association :flight, blueprint: FlightSerializer
end

class BookingSerializer < Blueprinter::Base
  identifier :id

  field :no_of_seats
  field :seat_price

  association :user, blueprint: UserSerializer
  association :flight, blueprint: FlightSerializer
end

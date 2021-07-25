class BookingSerializer < Blueprinter::Base
  identifier :id

  field :no_of_seats
  field :seat_price
  field :created_at
  field :updated_at

  association :user, blueprint: UserSerializer
  association :flight, blueprint: FlightSerializer
end

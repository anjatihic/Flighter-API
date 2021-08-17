module Api
  class BookingsQuery
    attr_reader :relation

    def initialize(relation: Booking.all)
      @relation = relation
    end

    def ordered_bookings
      relation.includes(:flight)
              .order('flights.departs_at', 'flights.name', 'bookings.created_at')
    end

    def for_public_user(current_user)
      relation.includes(:flight)
              .where('bookings.user_id = ?', current_user.id)
              .order('flights.departs_at', 'flights.name', 'bookings.created_at')
    end
  end
end

class BookingsQuery
  attr_reader :relation

  def initialize(relation: Booking.includes(:flight))
    @relation = relation
  end

  def ordered_bookings
    relation.order('flights.departs_at', 'flights.name', 'bookings.created_at')
  end

  def for_public_user(current_user)
    relation.where('bookings.user_id = ?', current_user.id)
  end
end

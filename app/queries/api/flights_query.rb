class FlightsQuery
  attr_reader :relation

  def initialize(relation: Flight.includes(:company))
    @relation = relation
  end

  def ordered_active_flights
    relation.where('CURRENT_TIMESTAMP < departs_at')
            .order('departs_at', 'name', 'created_at')
  end
end

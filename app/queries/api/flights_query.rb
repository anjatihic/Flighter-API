module Api
  class FlightsQuery
    attr_reader :relation

    def initialize(relation = Flight.all)
      @relation = relation
    end

    def ordered_active_flights
      relation.includes(:company)
              .where('CURRENT_TIMESTAMP < departs_at')
              .order('departs_at', 'name', 'created_at')
    end
  end
end

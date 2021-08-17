module Api
  class CompaniesQuery
    attr_reader :relation

    def initialize(relation: Company.all)
      @relation = relation
    end

    def ordered_companies_with_filter
      relation.select('companies.*')
              .includes(:flights)
              .where('flights.departs_at > ?', Time.zone.now)
              .order('companies.name')
              .references(:flights)
              .distinct
    end
  end
end

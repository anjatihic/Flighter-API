class CompaniesQuery
  attr_reader :relation

  def initialize(relation: Company.all)
    @relation = relation
  end

  def ordered_companies
    relation.order('name')
  end

  def active_companies
    relation.includes(:flights)
            .where('flight_departs_at < ?', Time.utc.now)
  end
end

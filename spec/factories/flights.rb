FactoryBot.define do
  factory :flight do
    association :company
    name { 'test' }
    departs_at { Time.now.utc.next_month }
    arrives_at { Time.now.utc.next_year }
    base_price { 200 }
    no_of_seats { 250 }
  end
end

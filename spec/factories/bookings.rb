FactoryBot.define do
  factory :booking do
    association :flight
    association :user

    no_of_seats { 100 }
    seat_price { 500 }
  end
end

# == Schema Information
#
# Table name: flights
#
#  id          :bigint           not null, primary key
#  name        :string
#  no_of_seats :integer
#  base_price  :integer
#  departs_at  :datetime
#  arrives_at  :datetime
#  company_id  :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :flight do
    association :company
    name { 'test' }
    departs_at { Time.now.utc.next_month }
    arrives_at { Time.now.utc.next_month + 2.hours }
    base_price { 200 }
    no_of_seats { 250 }
  end
end

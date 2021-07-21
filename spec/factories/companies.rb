FactoryBot.define do
  factory :company do
    name { "ime#{Time.now.utc}" }
  end
end

FactoryBot.define do
  factory :user do
    first_name { 'Ivan' }
    last_name { 'Horvat' }
    sequence(:email) { |n| "user-#{n}@email.com" }
  end
end

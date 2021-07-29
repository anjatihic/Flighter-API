# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  first_name      :string
#  last_name       :string
#  email           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :text             not null
#  token           :text
#  role            :string
#
FactoryBot.define do
  factory :user do
    first_name { 'Ivan' }
    last_name { 'Horvat' }
    sequence(:email) { |n| "user#{n}@email.com" }
    sequence(:password) { |n| "pass123#{n}" }
  end
end

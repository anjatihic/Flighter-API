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
class UserSerializer < Blueprinter::Base
  identifier :id

  field :first_name
  field :last_name
  field :email
  field :created_at
  field :updated_at
  field :role
end

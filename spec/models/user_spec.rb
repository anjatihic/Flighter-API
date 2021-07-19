RSpec.describe User do
  it 'is invalid without an email' do
    user = described_class.new(email: nil)
    user.valid?
    expect(user.errors[:email]).to include("can't be blank")
  end

  it 'is invalid when email is already taken' do
    described_class.create!(first_name: 'User', email: 'user@email.com')
    user = described_class.new(email: 'user@email.com')
    user.valid?
    expect(user.errors[:email]).to include('has already been taken')
  end

  it 'is invalid when email is already taken (case insensitive)' do
    described_class.create!(first_name: 'User', email: 'user@email.com')
    user = described_class.new(email: 'User@email.com')
    user.valid?
    expect(user.errors[:email]).to include('has already been taken')
  end

  it 'is invalid when email is not in the right format' do
    user = described_class.new(email: 'heirhierh')
    user.valid?
    expect(user.errors[:email]).to include('is invalid')
  end

  it 'is invalid without first name' do
    user = described_class.new(first_name: nil)
    user.valid?
    expect(user.errors[:first_name]).to include("can't be blank")
  end

  it 'is invalid when first_name is shorter than two characters' do
    user = described_class.new(first_name: 'A')
    user.valid?
    expect(user.errors[:first_name]).to include('is too short (minimum is 2 characters)')
  end
end

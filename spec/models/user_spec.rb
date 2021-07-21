RSpec.describe User do
  describe 'presence' do
    it { is_expected.to validate_presence_of(:email) }

    it { is_expected.to validate_presence_of(:first_name) }
  end

  describe 'uniqueness' do
    subject { FactoryBot.create(:user) }

    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'format' do
    it { is_expected.not_to allow_value('foo').for(:email) }
  end

  describe 'length' do
    it { is_expected.to validate_length_of(:first_name).is_at_least(2) }
  end
end

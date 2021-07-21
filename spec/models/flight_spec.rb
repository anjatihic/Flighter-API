RSpec.describe Flight do
  describe 'presence' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'uniqueness' do
    subject { FactoryBot.create(:flight) }

    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:company_id).case_insensitive }
  end
end

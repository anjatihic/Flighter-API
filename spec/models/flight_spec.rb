RSpec.describe Flight do
  describe 'presence' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'uniqueness' do
    before { FactoryBot.create(:flight) }

    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:company_id) }
  end
end

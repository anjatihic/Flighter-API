RSpec.describe Company do
  describe 'presence' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'uniqueness' do
    subject { described_class.new(name: 'New_airline') }

    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end
end

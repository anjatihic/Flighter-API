RSpec.describe Flight do
  subject { create(:flight) }

  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:company_id).case_insensitive }
end

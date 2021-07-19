RSpec.describe Flight do
  it 'is invalid without a name' do
    flight = described_class.new(name: nil)
    flight.valid?
    expect(flight.errors[:name]).to include("can't be blank")
  end
end

RSpec.describe Booking do
  let(:booking) { FactoryBot.create(:booking) }

  describe 'presence' do
    it { is_expected.to validate_presence_of(:seat_price) }

    it { is_expected.to validate_presence_of(:no_of_seats) }
  end

  describe 'numeritality' do
    it { is_expected.to validate_numericality_of(:seat_price) }

    it { is_expected.to validate_numericality_of(:no_of_seats) }
  end

  it 'is invalid when the departure time is in the past' do
    booking.flight.departs_at = Time.now.utc.last_month
    booking.valid?

    expect(booking.errors[:base]).to include("can't be in the past")
  end
end

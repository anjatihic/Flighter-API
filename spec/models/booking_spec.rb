RSpec.describe Booking do
  let(:booking) { create(:booking) }

  it { is_expected.to validate_presence_of(:seat_price) }
  it { is_expected.to validate_numericality_of(:seat_price) }

  it { is_expected.to validate_presence_of(:no_of_seats) }
  it { is_expected.to validate_numericality_of(:no_of_seats) }

  it 'is invalid when the departure time is in the past' do
    booking.flight.departs_at = Time.now.utc.last_month

    booking.valid?

    expect(booking.errors[:base]).to include("can't be in the past")
  end
end

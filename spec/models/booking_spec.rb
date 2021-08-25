# == Schema Information
#
# Table name: bookings
#
#  id          :bigint           not null, primary key
#  no_of_seats :integer
#  seat_price  :integer
#  user_id     :bigint
#  flight_id   :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
RSpec.describe Booking do
  let(:booking) { create(:booking) }

  it { is_expected.to validate_presence_of(:seat_price) }
  it { is_expected.to validate_numericality_of(:seat_price) }

  it { is_expected.to validate_presence_of(:no_of_seats) }
  it { is_expected.to validate_numericality_of(:no_of_seats) }

  # test for custom validation
  it 'is invalid when the departure time is in the past' do
    booking.flight.departs_at = Time.now.utc.last_month

    booking.valid?

    expect(booking.errors[:flight]).to include("can't be in the past")
  end
end

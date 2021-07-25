RSpec.describe 'Bookings API', type: :request do
  describe 'index action' do
    it 'returns the correct HTTP status code' do
      get '/api/bookings'

      expect(response).to have_http_status(:ok)
    end

    it 'returns the correct number of records' do
      create_list(:booking, 2)
      get '/api/bookings'

      expect(json_response['bookings'].size).to eq 2
    end
  end

  describe 'Show action' do
    let(:booking) { create(:booking) }

    it 'returns the correct HTTP status code' do
      get "/api/bookings/#{booking.id}"

      expect(response).to have_http_status(:ok)
    end

    it 'returns correct attributes' do
      get "/api/bookings/#{booking.id}"

      expect(json_response['booking']).to include('no_of_seats')
      expect(json_response['booking']).to include('user')
      expect(json_response['booking']).to include('seat_price')
      expect(json_response['booking']).to include('flight')
    end
  end

  describe 'Create action (valid params)' do
    let(:flight) { create(:flight) }
    let(:user) { create(:user) }
    let(:valid_params) do
      {
        booking:
        {
          no_of_seats: 2,
          user_id: user.id,
          seat_price: 400,
          flight_id: flight.id
        }
      }
    end

    it 'returns the correct HTTP status code' do
      post '/api/bookings', params: valid_params

      expect(response).to have_http_status(:created)
    end

    it 'returns correct attributes' do
      post '/api/bookings', params: valid_params

      expect(json_response['booking']).to include('no_of_seats')
      expect(json_response['booking']).to include('user')
      expect(json_response['booking']).to include('seat_price')
      expect(json_response['booking']).to include('flight')
    end

    it 'creates a new record' do
      post '/api/bookings', params: valid_params
      create_list(:booking, 2)

      get '/api/bookings'

      expect(json_response['bookings'].size).to eq 3
    end
  end

  describe 'Create action (invalid params)' do
    let(:user) { create(:user) }
    let(:flight) { create(:flight) }
    let(:invalid_params) do
      {
        booking:
        {
          user_id: user.id,
          seat_price: 400,
          flight_id: flight.id
        }
      }
    end

    it 'returns the correct HTTP status code' do
      post '/api/bookings', params: invalid_params

      expect(response).to have_http_status(:bad_request)
    end

    it 'returns a correct error message' do
      post '/api/bookings', params: invalid_params

      expect(json_response['errors']['no_of_seats']).to include("can't be blank")
    end
  end

  describe 'Update action (valid params)' do
    let(:booking) { create(:booking) }
    let(:valid_params) do
      {
        booking: { no_of_seats: 2 }
      }
    end

    it 'returns the correct HTTP status code' do
      put "/api/bookings/#{booking.id}", params: valid_params

      expect(response).to have_http_status(:ok)
    end

    it 'returns the correct attributes' do
      put "/api/bookings/#{booking.id}", params: valid_params

      expect(json_response['booking']).to include('no_of_seats')
      expect(json_response['booking']).to include('user')
      expect(json_response['booking']).to include('seat_price')
      expect(json_response['booking']).to include('flight')
    end

    it 'correctly updates data' do
      put "/api/bookings/#{booking.id}", params: valid_params

      get "/api/bookings/#{booking.id}"

      expect(json_response['booking']['no_of_seats']).to eq 2
    end
  end

  describe 'Update action (invalid params)' do
    let(:booking) { create(:booking) }
    let(:invalid_params) do
      {
        booking: { no_of_seats: -3 }
      }
    end

    it 'returns the correct HTTP status code' do
      put "/api/bookings/#{booking.id}", params: invalid_params

      expect(response).to have_http_status(:bad_request)
    end

    it 'returns a correct error message' do
      put "/api/bookings/#{booking.id}", params: invalid_params

      expect(json_response['errors']['no_of_seats']).to include('must be greater than 0')
    end
  end
end

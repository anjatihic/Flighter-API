RSpec.describe 'Bookings API', type: :request do
  describe 'GET /api/bookings, #index' do
    it 'returns the correct HTTP status code' do
      get '/api/bookings', headers: { 'Content-Type': 'application/json',
                                      'Accept': 'application/json' }

      expect(response).to have_http_status(:ok)
    end

    it 'returns the correct number of records' do
      create_list(:booking, 2)

      get '/api/bookings', headers: { 'Content-Type': 'application/json',
                                      'Accept': 'application/json' }

      expect(json_response['bookings'].size).to eq 2
    end

    it 'returns an empty json hash when no records in database' do
      get '/api/bookings', headers: { 'Content-Type': 'application/json',
                                      'Accept': 'application/json' }

      expect(json_response['bookings'].size).to eq 0
    end
  end

  describe 'GET /api/bookings/:id, #show' do
    let(:booking) { create(:booking) }

    it 'returns the correct HTTP status code' do
      get "/api/bookings/#{booking.id}", headers: { 'Content-Type': 'application/json',
                                                    'Accept': 'application/json' }

      expect(response).to have_http_status(:ok)
    end

    it 'returns correct attributes' do
      get "/api/bookings/#{booking.id}", headers: { 'Content-Type': 'application/json',
                                                    'Accept': 'application/json' }

      expect(json_response['booking']).to include('no_of_seats')
      expect(json_response['booking']).to include('user')
      expect(json_response['booking']).to include('seat_price')
      expect(json_response['booking']).to include('flight')
    end

    it 'returns correct error message when booking not found' do
      get "/api/bookings/#{booking.id + 1}", headers: { 'Accept': 'application/json' }

      expect(json_response).to include('errors')
    end
  end

  describe 'POST /api/bookings, #create' do
    context 'with valid params' do
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
        post '/api/bookings', params: valid_params.to_json,
                              headers: { 'Content-Type': 'application/json',
                                         'Accept': 'application/json' }

        expect(response).to have_http_status(:created)
      end

      it 'returns correct attributes' do
        post '/api/bookings', params: valid_params.to_json,
                              headers: { 'Content-Type': 'application/json',
                                         'Accept': 'application/json' }

        expect(json_response['booking']).to include('no_of_seats')
        expect(json_response['booking']).to include('user')
        expect(json_response['booking']).to include('seat_price')
        expect(json_response['booking']).to include('flight')
      end

      it 'creates a new record' do
        expect do
          post '/api/bookings', params: valid_params.to_json,
                                headers: { 'Content-Type': 'application/json',
                                           'Accept': 'application/json' }
        end.to change(Booking, :count).by(1)
      end
    end

    context 'with invalid params' do
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
        post '/api/bookings', params: invalid_params.to_json,
                              headers: { 'Content-Type': 'application/json',
                                         'Accept': 'application/json' }

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a correct error message' do
        post '/api/bookings', params: invalid_params.to_json,
                              headers: { 'Content-Type': 'application/json',
                                         'Accept': 'application/json' }

        expect(json_response['errors']['no_of_seats']).to include("can't be blank")
      end

      it "doesn't create a new record" do
        expect do
          post '/api/bookings', params: invalid_params.to_json,
                                headers: { 'Content-Type': 'application/json',
                                           'Accept': 'application/json' }
        end.to change(Booking, :count).by(0)
      end
    end
  end

  describe 'PUT /api/bookings/:id, #update' do
    context 'with valid params' do
      let(:booking) { create(:booking) }
      let(:valid_params) do
        {
          booking: { no_of_seats: 2 }
        }
      end

      it 'returns the correct HTTP status code' do
        put "/api/bookings/#{booking.id}", params: valid_params.to_json,
                                           headers: { 'Content-Type': 'application/json',
                                                      'Accept': 'application/json' }

        expect(response).to have_http_status(:ok)
      end

      it 'returns the correct attributes' do
        put "/api/bookings/#{booking.id}", params: valid_params.to_json,
                                           headers: { 'Content-Type': 'application/json',
                                                      'Accept': 'application/json' }

        expect(json_response['booking']).to include('no_of_seats')
        expect(json_response['booking']).to include('user')
        expect(json_response['booking']).to include('seat_price')
        expect(json_response['booking']).to include('flight')
      end

      it 'correctly updates data' do
        put "/api/bookings/#{booking.id}", params: valid_params.to_json,
                                           headers: { 'Content-Type': 'application/json',
                                                      'Accept': 'application/json' }

        expect(Booking.find(booking.id)['no_of_seats']).to eq 2
      end
    end

    context 'with invalid params' do
      let(:booking) { create(:booking) }
      let(:invalid_params) do
        {
          booking: { no_of_seats: -3 }
        }
      end

      it 'returns the correct HTTP status code' do
        put "/api/bookings/#{booking.id}", params: invalid_params.to_json,
                                           headers: { 'Content-Type': 'application/json',
                                                      'Accept': 'application/json' }

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a correct error message' do
        put "/api/bookings/#{booking.id}", params: invalid_params.to_json,
                                           headers: { 'Content-Type': 'application/json',
                                                      'Accept': 'application/json' }
        expect(json_response['errors']['no_of_seats']).to include('must be greater than 0')
        expect(Booking.find(booking.id)['no_of_seats']).to eq(booking.no_of_seats)
      end
    end
  end

  describe 'DELETE /api/bookings/:id, #destroy' do
    let(:booking) { create(:booking) }

    it 'removes a booking from database' do
      delete "/api/bookings/#{booking.id}", headers: { 'Content-Type': 'application/json',
                                                       'Accept': 'application/json' }

      expect(Booking.find_by(id: booking.id)).to eq nil
    end

    it 'returns a correct HTTP status code' do
      delete "/api/bookings/#{booking.id}", headers: { 'Content-Type': 'application/json',
                                                       'Accept': 'application/json' }

      expect(response).to have_http_status(:no_content)
    end
  end
end

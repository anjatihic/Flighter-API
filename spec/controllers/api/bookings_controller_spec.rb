# rubocop:disable RSpec/NestedGroups, RSpec/MultipleMemoizedHelpers
RSpec.describe 'Bookings API', type: :request do
  let(:request_headers) do
    {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'abc'
    }
  end

  let(:no_token_request_headers) do
    {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }
  end

  let(:admin_request_headers) do
    {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'admin'
    }
  end

  let!(:admin_user) { create(:user, token: 'admin', role: 'admin') } # rubocop:disable RSpec/LetSetup

  describe 'GET /api/bookings, #index' do
    context 'when unauthenticated' do
      it 'returns the correct HTTP status code' do
        get '/api/bookings', headers: no_token_request_headers

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error message' do
        get '/api/bookings', headers: no_token_request_headers

        expect(json_response).to include('errors')
      end
    end

    context 'when authenticated' do
      it 'returns the correct HTTP status code' do
        create(:user, token: 'abc')

        get '/api/bookings', headers: request_headers

        expect(response).to have_http_status(:ok)
      end

      it 'returns an empty json hash when no records belong to user' do
        create(:user, token: 'abc')
        create_list(:booking, 2)
        get '/api/bookings', headers: request_headers

        expect(json_response['bookings'].size).to eq 0
      end

      it 'returns sorted bookings' do
        creator = create(:user, token: 'abc')
        flight1 = create(:flight, departs_at: Time.now.utc.next_week)
        flight2 = create(:flight, name: 'zanzibar')
        first_booking = create(:booking, user: creator, flight: flight1)
        second_booking = create(:booking, user: creator, flight: flight2)
        third_booking = create(:booking, user: creator)

        expected_order = [first_booking.id, second_booking.id, third_booking.id]

        get '/api/bookings', headers: request_headers

        bookings = json_response['bookings'].map { |booking| booking['id'] }

        expect(bookings).to eq expected_order
      end

      it 'returns only bookings with active flights when filter=active added' do
        creator = create(:user, token: 'abc')
        flight = create(:flight, departs_at: Time.now.utc + 1.second)
        create(:booking, user: creator, flight: flight)
        booking1 = create(:booking, user: creator)
        booking2 = create(:booking, user: creator)

        expected_response = [booking1.id, booking2.id]

        sleep(1)
        get '/api/bookings?filter=active', headers: request_headers

        bookings = json_response['bookings'].map { |booking| booking['id'] }

        expect(bookings).to eq expected_response
      end

      it 'returns the total price for each booking' do
        creator = create(:user, token: 'abc')
        create(:booking, no_of_seats: 3, seat_price: 10, user: creator)

        get '/api/bookings', headers: request_headers

        expect(json_response['bookings'][0]['total_price']).to eq 30
      end
    end

    context 'when authorized' do
      it 'returns the correct HTTP status code' do
        get '/api/bookings', headers: admin_request_headers

        expect(response).to have_http_status(:ok)
      end

      it 'returns all the bookings, even if user not a creator of them' do
        create_list(:booking, 2)

        get '/api/bookings', headers: admin_request_headers

        expect(json_response['bookings'].size).to eq 2
      end

      it 'returns an empty json hash when there are no bookings' do
        get '/api/bookings', headers: admin_request_headers

        expect(json_response['bookings'].size).to eq 0
      end
    end
  end

  describe 'GET /api/bookings/:id, #show' do
    let(:booking) { create(:booking) }

    context 'when unauthenticated' do
      it 'returns the correct HTTP status code' do
        get "/api/bookings/#{booking.id}", headers: no_token_request_headers

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error message' do
        get "/api/bookings/#{booking.id}", headers: no_token_request_headers

        expect(json_response).to include('errors')
      end
    end

    context 'when authenticated' do
      context 'with invalid params' do
        it 'returns the correct HTTP status code' do
          create(:user, token: 'abc')
          get "/api/bookings/#{booking.id}", headers: request_headers

          expect(response).to have_http_status(:forbidden)
        end

        it 'returns an error message' do
          create(:user, token: 'abc')

          get "/api/bookings/#{booking.id}", headers: request_headers

          expect(json_response).to include('errors')
        end
      end

      context 'with valid params' do
        let!(:user) { create(:user, token: 'abc') }
        let(:booking) { create(:booking, user: user) }

        it 'returns the correct HTTP status code' do
          get "/api/bookings/#{booking.id}", headers: request_headers

          expect(response).to have_http_status(:ok)
        end

        it 'returns the correct attributes' do
          get "/api/bookings/#{booking.id}", headers: request_headers

          expect(json_response['booking']).to include('no_of_seats')
          expect(json_response['booking']).to include('user')
          expect(json_response['booking']).to include('seat_price')
          expect(json_response['booking']).to include('flight')
        end
      end
    end

    context 'when authorized' do
      context 'with valid params' do
        it 'returns the correct HTTP status code' do
          get "/api/bookings/#{booking.id}", headers: admin_request_headers

          expect(response).to have_http_status(:ok)
        end

        it 'returns the correct attributes' do
          get "/api/bookings/#{booking.id}", headers: admin_request_headers

          expect(json_response['booking']).to include('no_of_seats')
          expect(json_response['booking']).to include('user')
          expect(json_response['booking']).to include('seat_price')
          expect(json_response['booking']).to include('flight')
        end
      end
    end
  end

  describe 'POST /api/bookings, #create' do
    context 'when unauthenticated' do
      let(:flight) { create(:flight) }
      let(:params) do
        {
          no_of_seats: 2,
          seat_price: 400,
          flight_id: flight.id
        }
      end

      it 'returns the correct HTTP status code' do
        post '/api/bookings', params: params.to_json,
                              headers: no_token_request_headers

        expect(response).to have_http_status(:unauthorized)
      end

      it "doesn't create a new record" do
        expect do
          post '/api/bookings', params: params.to_json,
                                headers: no_token_request_headers
        end.not_to change(Booking, :count)
      end
    end

    context 'when authenticated' do
      context 'with valid params' do
        let!(:user) { create(:user, token: 'abc') } # rubocop:disable  RSpec/LetSetup
        let(:flight) { create(:flight) }
        let(:valid_params) do
          {
            booking:
            {
              no_of_seats: 2,
              seat_price: 1000,
              flight_id: flight.id
            }
          }
        end

        it 'returns the correct HTTP status code' do
          post '/api/bookings', params: valid_params.to_json,
                                headers: request_headers

          expect(response).to have_http_status(:created)
        end

        it 'returns correct attributes' do
          post '/api/bookings', params: valid_params.to_json,
                                headers: request_headers

          expect(json_response['booking']).to include('no_of_seats')
          expect(json_response['booking']).to include('user')
          expect(json_response['booking']).to include('seat_price')
          expect(json_response['booking']).to include('flight')
        end

        it 'creates a new record' do
          expect do
            post '/api/bookings', params: valid_params.to_json,
                                  headers: request_headers
          end.to change(Booking, :count).by(1)
        end
      end

      context 'with invalid params' do
        let(:invalid_params) do
          {
            booking:
            {
              no_of_seats: 2,
              seat_price: 400
            }
          }
        end

        it 'returns the correct HTTP status code' do
          post '/api/bookings', params: invalid_params.to_json,
                                headers: admin_request_headers

          expect(response).to have_http_status(:bad_request)
        end

        it 'returns an error message' do
          post '/api/bookings', params: invalid_params.to_json,
                                headers: admin_request_headers

          expect(json_response).to include('errors')
        end

        it "doesn't create a new record" do
          expect do
            post '/api/bookings', params: invalid_params.to_json,
                                  headers: admin_request_headers
          end.not_to change(Booking, :count)
        end

        it 'validates if a booking overbooks a flight' do
          flight = create(:flight, no_of_seats: 10)
          booking = build(:booking, flight: flight, no_of_seats: 15)

          expect(booking.valid?).to be false
        end
      end
    end

    context 'when authorized' do
      let(:flight) { create(:flight) }
      let(:user) { create(:user) }

      context 'with valid params' do
        let(:valid_params) do
          {
            booking:
            {
              no_of_seats: 2,
              seat_price: 1000,
              flight_id: flight.id,
              user_id: user.id
            }
          }
        end

        it 'returns the correct HTTP status code' do
          post '/api/bookings', params: valid_params.to_json,
                                headers: admin_request_headers

          expect(response).to have_http_status(:created)
        end

        it 'returns correct attributes' do
          post '/api/bookings', params: valid_params.to_json,
                                headers: admin_request_headers

          expect(json_response['booking']).to include('no_of_seats')
          expect(json_response['booking']).to include('user')
          expect(json_response['booking']).to include('seat_price')
          expect(json_response['booking']).to include('flight')
        end

        it 'creates a new record' do
          expect do
            post '/api/bookings', params: valid_params.to_json,
                                  headers: admin_request_headers
          end.to change(Booking, :count).by(1)
        end
      end

      context 'with invalid params' do
        let(:invalid_params) do
          {
            booking:
            {
              no_of_seats: 2,
              user_id: user.id,
              flight_id: flight.id
            }
          }
        end

        it 'returns the correct HTTP status code' do
          post '/api/bookings', params: invalid_params.to_json,
                                headers: admin_request_headers

          expect(response).to have_http_status(:bad_request)
        end

        it 'returns an error message' do
          post '/api/bookings', params: invalid_params.to_json,
                                headers: admin_request_headers

          expect(json_response).to include('errors')
        end

        it "doesn't create a new record" do
          expect do
            post '/api/bookings', params: invalid_params.to_json,
                                  headers: admin_request_headers
          end.not_to change(Booking, :count)
        end
      end
    end
  end

  describe 'PUT /api/bookings/:id, update' do
    context 'when unauthenticated' do
      let(:booking) { create(:booking) }
      let(:params) do
        {
          booking: { no_of_seats: 2 }
        }
      end

      it 'returns the correct HTTP status code' do
        put "/api/bookings/#{booking.id}", params: params.to_json,
                                           headers: no_token_request_headers

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error message' do
        put "/api/bookings/#{booking.id}", params: params.to_json,
                                           headers: no_token_request_headers

        expect(json_response).to include('errors')
      end
    end

    context 'when authenticated' do
      context 'with valid params' do
        let!(:user) { create(:user, token: 'abc') }
        let(:booking) { create(:booking, user: user) }
        let(:valid_params) do
          {
            booking: { no_of_seats: 2 }
          }
        end

        it 'returns the correct HTTP status code' do
          put "/api/bookings/#{booking.id}", params: valid_params.to_json,
                                             headers: request_headers

          expect(response).to have_http_status(:ok)
        end

        it 'returns the correct attributes' do
          put "/api/bookings/#{booking.id}", params: valid_params.to_json,
                                             headers: request_headers

          expect(json_response['booking']).to include('no_of_seats')
          expect(json_response['booking']).to include('user')
          expect(json_response['booking']).to include('seat_price')
          expect(json_response['booking']).to include('flight')
        end

        it 'correctly updates data' do
          put "/api/bookings/#{booking.id}", params: valid_params.to_json,
                                             headers: request_headers

          expect(booking.reload.no_of_seats).to eq valid_params[:booking][:no_of_seats]
        end

        it "can't update data of a booking that doesn't belong to user" do
          someones_booking = create(:booking)
          put "/api/bookings/#{someones_booking.id}", params: valid_params.to_json,
                                                      headers: request_headers

          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'with invalid params' do
        let(:user) { create(:user, token: 'abc') }
        let(:booking) { create(:booking, user: user) }
        let(:invalid_params) do
          {
            booking: { no_of_seats: -3 }
          }
        end

        it 'returns the correct HTTP status code' do
          put "/api/bookings/#{booking.id}", params: invalid_params.to_json,
                                             headers: request_headers

          expect(response).to have_http_status(:bad_request)
        end

        it 'returns an error message' do
          put "/api/bookings/#{booking.id}", params: invalid_params.to_json,
                                             headers: request_headers

          expect(json_response).to include('errors')
        end

        it "doesn't update database" do
          put "/api/bookings/#{booking.id}", params: invalid_params.to_json,
                                             headers: request_headers

          expect(Booking.find(booking.id).no_of_seats).to eq(booking.no_of_seats)
        end
      end
    end

    context 'when authorized' do
      let(:booking) { create(:booking) }
      let(:valid_params) do
        {
          booking: { no_of_seats: 2 }
        }
      end

      it "can update record that doesn't belong to current user" do
        put "/api/bookings/#{booking.id}", params: valid_params.to_json,
                                           headers: admin_request_headers

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'DELETE /api/bookings/:id, #destroy' do
    context 'when unauthenticated' do
      let!(:booking) { create(:booking) }

      it 'returns the correct HTTP status code' do
        delete "/api/bookings/#{booking.id}", headers: no_token_request_headers

        expect(response).to have_http_status(:unauthorized)
      end

      it "doesn't delete the record from database" do
        expect do
          delete "/api/bookings/#{booking.id}", headers: no_token_request_headers
        end.not_to change(Booking, :count)
      end
    end

    context 'when authenticated' do
      let!(:user) { create(:user, token: 'abc') }
      let(:booking) { create(:booking, user: user) }

      it 'returns the correct HTTP status code' do
        delete "/api/bookings/#{booking.id}", headers: request_headers

        expect(response).to have_http_status(:no_content)
      end

      it 'removes the record from database' do
        delete "/api/bookings/#{booking.id}", headers: request_headers

        expect(Booking.find_by(id: booking.id)).to eq nil
      end

      it "can't delete record that doesn't belong to current user" do
        someones_booking = create(:booking)

        delete "/api/bookings/#{someones_booking.id}", headers: request_headers

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when authorized' do
      let(:booking) { create(:booking) }

      it "removes record from database even if the current user doesn't own the booking" do
        delete "/api/bookings/#{booking.id}", headers: admin_request_headers

        expect(Booking.find_by(id: booking.id)).to eq nil
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups, RSpec/MultipleMemoizedHelpers

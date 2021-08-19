# rubocop:disable RSpec/NestedGroups, RSpec/MultipleMemoizedHelpers
RSpec.describe 'Flights API', type: :request do
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

  describe 'GET /api/flights, #index' do
    it 'returns the correct HTTP status code' do
      get '/api/flights', headers: no_token_request_headers

      expect(response).to have_http_status(:ok)
    end

    it 'returns the correct number of records' do
      create_list(:flight, 2)
      get '/api/flights', headers: no_token_request_headers

      expect(json_response['flights'].size).to eq 2
    end

    it 'returns an empty json hash when no records in database' do
      get '/api/flights', headers: no_token_request_headers

      expect(json_response['flights'].size).to eq 0
    end

    it 'returns ordered flights' do
      second_flight = create(:flight, name: 'zanzibar')
      first_flight = create(:flight, departs_at: Time.now.utc.next_week)
      third_flight = create(:flight)

      expected_order = [first_flight.id, second_flight.id, third_flight.id]

      get '/api/flights', headers: no_token_request_headers

      flights = json_response['flights'].map { |flight| flight['id'] }

      expect(flights).to eq expected_order
    end

    it 'responds only with active flights' do
      create(:flight, departs_at: Time.now.utc + 1.second)
      flight1 = create(:flight)
      flight2 = create(:flight)

      expected_response = [flight1.id, flight2.id]

      sleep(1)
      get '/api/flights', headers: no_token_request_headers

      flights = json_response['flights'].map { |flight| flight['id'] }

      expect(flights).to eq expected_response
    end

    it 'shows number of booked seats on flight' do
      create(:flight)

      get '/api/flights', headers: no_token_request_headers

      expect(json_response['flights'][0]).to include('no_of_booked_seats')
    end

    it 'shows the name of the company for each flight' do
      create(:flight)

      get '/api/flights', headers: no_token_request_headers

      expect(json_response['flights'][0]).to include('company_name')
    end

    it 'shows the current price for each flight' do
      create(:flight)

      get '/api/flights', headers: no_token_request_headers

      expect(json_response['flights'][0]).to include('current_price')
    end

    context 'with filters' do
      it 'responds with flights that contain a searched name entry' do
        wanted_flight1 = create(:flight, name: 'WANTED FLIGHT')
        wanted_flight2 = create(:flight, name: 'wanted flight')
        create(:flight)

        expected_response = [wanted_flight1.id, wanted_flight2.id]

        get '/api/flights?name_cont=anted', headers: no_token_request_headers

        flights_in_response = json_response['flights'].map { |flight| flight['id'] }

        expect(flights_in_response).to eq expected_response
      end

      it 'responds with flights that have a searched departure' do
        wanted_time = Time.now.utc + 1.week
        create(:flight)
        wanted_flight = create(:flight, departs_at: wanted_time)

        get "/api/flights?departs_at_eq=#{wanted_time}", headers: no_token_request_headers

        expect(json_response['flights'][0]['id']).to eq wanted_flight.id
      end

      it 'responds flights with available number of wanted seats' do
        flight1 = create(:flight, no_of_seats: 10)
        create(:booking, no_of_seats: 8, flight: flight1)
        wanted_flight = create(:flight, no_of_seats: 30)
        wanted_seats = 10

        get "/api/flights?no_of_available_seats_gteq=#{wanted_seats}",
            headers: no_token_request_headers

        expect(json_response['flights'].size).to eq 1
        expect(json_response['flights'][0]['id']).to eq wanted_flight.id
      end
    end
  end

  describe 'GET /api/flights, #show' do
    let(:flight) { create(:flight) }

    it 'returns the correct HTTP status code' do
      get "/api/flights/#{flight.id}", headers: no_token_request_headers

      expect(response).to have_http_status(:ok)
    end

    it 'returns correct attributes' do
      get "/api/flights/#{flight.id}", headers: no_token_request_headers

      expect(json_response['flight']).to include('name')
    end

    it 'returns error when flight not found' do
      get "/api/flights/#{flight.id + 1}", headers: no_token_request_headers

      expect(json_response).to include('errors')
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/flights, #create' do
    context 'when unauthenticated' do
      let(:create_params) do
        {
          flight: { name: 'flight name' }
        }
      end

      it 'returns the correct HTTP status code' do
        post '/api/flights', params: create_params.to_json,
                             headers: no_token_request_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      let(:create_params) do
        {
          flight: { name: 'Flight name' }
        }
      end
      let(:user) { create(:user, token: 'abc') }

      it 'returns the correct HTTP status code' do
        post '/api/flights', params: create_params.to_json,
                             headers: request_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authorized' do
      context 'with valid params' do
        let(:company) { create(:company) }
        let(:valid_params) do
          {
            flight:
            {
              name: 'test',
              departs_at: Time.now.utc.next_month,
              arrives_at: Time.now.utc.next_month + 2.hours,
              base_price: 500,
              no_of_seats: 300,
              company_id: company.id
            }
          }
        end

        it 'returns the correct HTTP status code' do
          post '/api/flights', params: valid_params.to_json,
                               headers: admin_request_headers

          expect(response).to have_http_status(:created)
        end

        it 'returns the correct attributes' do
          post '/api/flights', params: valid_params.to_json,
                               headers: admin_request_headers

          expect(json_response['flight']).to include('name')
        end

        it 'creates a new record' do
          expect do
            post '/api/flights', params: valid_params.to_json,
                                 headers: admin_request_headers
          end.to change(Flight, :count).by(1)
        end
      end

      context 'with invalid params' do
        let(:invalid_params) do
          {
            flight: { name: '' }
          }
        end

        it 'returns the correct HTTP status code' do
          post '/api/flights', params: invalid_params.to_json,
                               headers: admin_request_headers

          expect(response).to have_http_status(:bad_request)
        end

        it 'returns an error message' do
          post '/api/flights', params: invalid_params.to_json,
                               headers: admin_request_headers

          expect(json_response).to include('errors')
        end

        it "doesn't create a new record" do
          expect do
            post '/api/flights', params: invalid_params.to_json,
                                 headers: admin_request_headers
          end.not_to change(Flight, :count)
        end

        it 'validates if the flights whitin the company overlap' do
          company = create(:company)
          create(:flight, company: company)
          new_flight = build(:flight, company: company)

          expect(new_flight.valid?).to be false
        end

        it 'validates if the flights whitin the company overlap (edge case)' do
          company = create(:company)
          flight = create(:flight, company: company)
          new_flight = build(:flight,
                             name: 'new_name',
                             company: company,
                             departs_at: flight.arrives_at,
                             arrives_at: Time.now.utc + 2.months)

          expect(new_flight.valid?).to be false
        end
      end
    end
  end

  describe 'PUT /api/flights/:id, #update' do
    context 'when unauthenticated' do
      let(:update_params) do
        {
          flight: { name: 'FLight name' }
        }
      end
      let(:flight) { create(:flight) }

      it 'returns the correct HTTP status code' do
        put "/api/flights/#{flight.id}", params: update_params.to_json,
                                         headers: no_token_request_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authorized' do
      context 'with valid params' do
        let(:valid_params) do
          {
            flight: { name: 'Flight name' }
          }
        end
        let(:flight) { create(:flight) }

        it 'returns the correct HTTP status code' do
          put "/api/flights/#{flight.id}", params: valid_params.to_json,
                                           headers: admin_request_headers

          expect(response).to have_http_status(:ok)
        end

        it 'returns the correct attributes' do
          put "/api/flights/#{flight.id}", params: valid_params.to_json,
                                           headers: admin_request_headers

          expect(json_response['flight']).to include('name')
        end

        it 'correctly updates data' do
          put "/api/flights/#{flight.id}", params: valid_params.to_json,
                                           headers: admin_request_headers

          expect(flight.reload.name).to include(valid_params[:flight][:name])
        end
      end

      context 'with invalid params' do
        let(:company) { create(:company) }
        let(:invalid_params) do
          {
            company: { name: '' }
          }
        end

        it 'returns the correct HTTP status code' do
          put "/api/companies/#{company.id}", params: invalid_params.to_json,
                                              headers: admin_request_headers

          expect(response).to have_http_status(:bad_request)
        end

        it 'returns an error message' do
          put "/api/companies/#{company.id}", params: invalid_params.to_json,
                                              headers: admin_request_headers

          expect(json_response).to include('errors')
          expect(Company.find(company.id).name).to eq(company.name)
        end
      end
    end
  end

  describe 'DELETE /api/flights/:id, #destroy' do
    let(:flight) { create(:flight) }

    context 'when unauthenticated' do
      it 'returns the correct HTTP status code' do
        delete "/api/flights/#{flight.id}", headers: no_token_request_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      it 'returns the correct HTTP status code' do
        delete "/api/flights/#{flight.id}", headers: request_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authorized' do
      context 'with valid params' do
        it 'returns the correct HTTP status code' do
          delete "/api/flights/#{flight.id}", headers: admin_request_headers

          expect(response).to have_http_status(:no_content)
        end

        it 'removes the record from database' do
          delete "/api/flights/#{flight.id}", headers: admin_request_headers

          expect(Flight.find_by(id: flight.id)).to eq nil
        end
      end

      context 'with invalid params' do
        it 'returns the correct HTTP status code' do
          delete "/api/flights/#{flight.id + 1}", headers: admin_request_headers

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups, RSpec/MultipleMemoizedHelpers

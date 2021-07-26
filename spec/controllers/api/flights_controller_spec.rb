RSpec.describe 'Flights API', type: :request do
  describe 'GET /api/flights, #index' do
    it 'returns the correct HTTP status code' do
      get '/api/flights', headers: { 'Content-Type': 'application/json',
                                     'Accept': 'application/json' }

      expect(response).to have_http_status(:ok)
    end

    it 'returns the correct number of records' do
      create_list(:flight, 2)
      get '/api/flights', headers: { 'Content-Type': 'application/json',
                                     'Accept': 'application/json' }

      expect(json_response['flights'].size).to eq 2
    end

    it 'returns an empty json hash when no records in database' do
      get '/api/flights', headers: { 'Content-Type': 'application/json',
                                     'Accept': 'application/json' }

      expect(json_response['flights'].size).to eq 0
    end
  end

  describe 'GET /api/flights, #show' do
    let(:flight) { create(:flight) }

    it 'returns the correct HTTP status code' do
      get "/api/flights/#{flight.id}", headers: { 'Content-Type': 'application/json',
                                                  'Accept': 'application/json' }

      expect(response).to have_http_status(:ok)
    end

    it 'returns correct attributes' do
      get "/api/flights/#{flight.id}", headers: { 'Content-Type': 'application/json',
                                                  'Accept': 'application/json' }

      expect(json_response['flight']).to include('name')
      expect(json_response['flight']).to include('no_of_seats')
      expect(json_response['flight']).to include('base_price')
      expect(json_response['flight']).to include('departs_at')
      expect(json_response['flight']).to include('arrives_at')
      expect(json_response['flight']).to include('company')
    end

    it 'returns an error message when flight not found' do
      get "/api/flights/#{flight.id + 1}", headers: { 'Content-Type': 'application/json',
                                                      'Accept': 'application/json' }

      expect(json_response).to include('errors')
    end
  end

  describe 'POST /api/flights, #create' do
    context 'with valid params' do
      let(:company) { create(:company) }
      let(:valid_params) do
        {
          flight:
          {
            name: 'Test flight',
            no_of_seats: 300,
            base_price: 500,
            departs_at: Time.now.utc.next_month,
            arrives_at: Time.now.utc.next_month + 3.hours,
            company_id: company.id
          }
        }
      end

      it 'returns the correct HTTP status code' do
        post '/api/flights', params: valid_params.to_json,
                             headers: { 'Content-Type': 'application/json',
                                        'Accept': 'application/json' }

        expect(response).to have_http_status(:created)
      end

      it 'returns correct attributes' do
        post '/api/flights', params: valid_params.to_json,
                             headers: { 'Content-Type': 'application/json',
                                        'Accept': 'application/json' }

        expect(json_response['flight']).to include('name')
        expect(json_response['flight']).to include('no_of_seats')
        expect(json_response['flight']).to include('base_price')
        expect(json_response['flight']).to include('departs_at')
        expect(json_response['flight']).to include('arrives_at')
        expect(json_response['flight']).to include('company')
      end

      it 'creates a new record' do
        expect do
          post '/api/flights', params: valid_params.to_json,
                               headers: { 'Content-Type': 'application/json',
                                          'Accept': 'application/json' }
        end.to change(Flight, :count).by(1)
      end
    end

    context 'with invalid params' do
      let(:company) { create(:company) }
      let(:invalid_params) do
        {
          flight:
          {
            name: 'Test flight',
            no_of_seats: 300,
            base_price: 500,
            arrives_at: Time.now.utc.next_month + 3.hours,
            company_id: company.id
          }
        }
      end

      it 'returns the correct HTTP status code' do
        post '/api/flights', params: invalid_params.to_json,
                             headers: { 'Content-Type': 'application/json',
                                        'Accept': 'application/json' }

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a correct error message' do
        post '/api/flights', params: invalid_params.to_json,
                             headers: { 'Content-Type': 'application/json',
                                        'Accept': 'application/json' }

        expect(json_response['errors']['departs_at']).to include("can't be blank")
      end

      it "doesn't create a new record" do
        expect do
          post '/api/flights', params: invalid_params.to_json,
                               headers: { 'Content-Type': 'application/json',
                                          'Accept': 'application/json' }
        end.to change(Flight, :count).by(0)
      end
    end
  end

  describe 'PUT /api/flights/:id, #update' do
    context 'with valid params' do
      let(:flight) { create(:flight) }
      let(:valid_params) do
        {
          flight: { name: 'New flight' }
        }
      end

      it 'returns the correct HTTP status code' do
        put "/api/flights/#{flight.id}", params: valid_params.to_json,
                                         headers: { 'Content-Type': 'application/json',
                                                    'Accept': 'application/json' }

        expect(response).to have_http_status(:ok)
      end

      it 'returns the correct attributes' do
        put "/api/flights/#{flight.id}", params: valid_params.to_json,
                                         headers: { 'Content-Type': 'application/json',
                                                    'Accept': 'application/json' }

        expect(json_response['flight']).to include('name')
        expect(json_response['flight']).to include('no_of_seats')
        expect(json_response['flight']).to include('base_price')
        expect(json_response['flight']).to include('departs_at')
        expect(json_response['flight']).to include('arrives_at')
        expect(json_response['flight']).to include('company')
      end

      it 'correctly updates data' do
        put "/api/flights/#{flight.id}", params: valid_params.to_json,
                                         headers: { 'Content-Type': 'application/json',
                                                    'Accept': 'application/json' }

        expect(Flight.find(flight.id)['name']).to include('New flight')
      end
    end

    context 'with invalid params' do
      let(:flight) { create(:flight) }
      let(:invalid_params) do
        {
          flight: { base_price: -200 }
        }
      end

      it 'returns the correct HTTP status code' do
        put "/api/flights/#{flight.id}", params: invalid_params.to_json,
                                         headers: { 'Content-Type': 'application/json',
                                                    'Accept': 'application/json' }

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a correct error message' do
        put "/api/flights/#{flight.id}", params: invalid_params.to_json,
                                         headers: { 'Content-Type': 'application/json',
                                                    'Accept': 'application/json' }

        expect(json_response['errors']['base_price']).to include('must be greater than 0')
        expect(Flight.find(flight.id)['base_price']).to eq(flight.base_price)
      end
    end
  end

  describe 'DELETE /api/flights/:id, #destroy' do
    let(:flight) { create(:flight) }

    it 'removes a flights from database' do
      delete "/api/flights/#{flight.id}", headers: { 'Content-Type': 'application/json',
                                                     'Accept': 'application/json' }

      expect(Flight.find_by(id: flight.id)).to eq nil
    end

    it 'returns a correct HTTP status code' do
      delete "/api/flights/#{flight.id}", headers: { 'Content-Type': 'application/json',
                                                     'Accept': 'application/json' }

      expect(response).to have_http_status(:no_content)
    end
  end
end

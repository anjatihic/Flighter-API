RSpec.describe 'Flights API', type: :request do
  describe 'index action' do
    it 'returns the correct HTTP status code' do
      get '/api/flights'

      expect(response).to have_http_status(:ok)
    end

    it 'returns the correct number of records' do
      create_list(:flight, 2)
      get '/api/flights'

      expect(json_response['flights'].size).to eq 2
    end
  end

  describe 'Show action' do
    let(:flight) { create(:flight) }

    it 'returns the correct HTTP status code' do
      get "/api/flights/#{flight.id}"

      expect(response).to have_http_status(:ok)
    end

    it 'returns correct attributes' do
      get "/api/flights/#{flight.id}"

      expect(json_response['flight']).to include('name')
      expect(json_response['flight']).to include('no_of_seats')
      expect(json_response['flight']).to include('base_price')
      expect(json_response['flight']).to include('departs_at')
      expect(json_response['flight']).to include('arrives_at')
      expect(json_response['flight']).to include('company')
    end
  end

  describe 'Create action (valid params)' do
    let(:company) { create(:company) }
    let(:valid_params) do
      {
        name: 'Test flight',
        no_of_seats: 300,
        base_price: 500,
        departs_at: Time.now.utc.next_month,
        arrives_at: Time.now.utc.next_month + 3.hours,
        company_id: company.id
      }
    end

    it 'returns the correct HTTP status code' do
      post '/api/flights', params: valid_params

      expect(response).to have_http_status(:created)
    end

    it 'returns correct attributes' do
      post '/api/flights', params: valid_params

      expect(json_response['flight']).to include('name')
      expect(json_response['flight']).to include('no_of_seats')
      expect(json_response['flight']).to include('base_price')
      expect(json_response['flight']).to include('departs_at')
      expect(json_response['flight']).to include('arrives_at')
      expect(json_response['flight']).to include('company')
    end

    it 'creates a new record' do
      post '/api/flights', params: valid_params
      create_list(:flight, 2)

      get '/api/flights'

      expect(json_response['flights'].size).to eq 3
    end
  end

  describe 'Create action (invalid params)' do
    let(:company) { create(:company) }
    let(:invalid_params) do
      {
        name: 'Test flight',
        no_of_seats: 300,
        base_price: 500,
        arrives_at: Time.now.utc.next_month + 3.hours,
        company_id: company.id
      }
    end

    it 'returns the correct HTTP status code' do
      post '/api/flights', params: invalid_params

      expect(response).to have_http_status(:bad_request)
    end

    it 'returns a correct error message' do
      post '/api/flights', params: invalid_params

      expect(json_response['errors']['departs_at']).to include("can't be blank")
    end
  end

  describe 'Update action (valid params)' do
    let(:flight) { create(:flight) }
    let(:valid_params) do
      {
        name: 'New flight'
      }
    end

    it 'returns the correct HTTP status code' do
      put "/api/flights/#{flight.id}", params: valid_params

      expect(response).to have_http_status(:ok)
    end

    it 'returns the correct attributes' do
      put "/api/flights/#{flight.id}", params: valid_params

      expect(json_response['flight']).to include('name')
      expect(json_response['flight']).to include('no_of_seats')
      expect(json_response['flight']).to include('base_price')
      expect(json_response['flight']).to include('departs_at')
      expect(json_response['flight']).to include('arrives_at')
      expect(json_response['flight']).to include('company')
    end

    it 'correctly updates data' do
      put "/api/flights/#{flight.id}", params: valid_params

      get "/api/flights/#{flight.id}"

      expect(json_response['flight']['name']).to include('New flight')
    end
  end

  describe 'Update action (invalid params)' do
    let(:flight) { create(:flight) }
    let(:invalid_params) do
      {
        base_price: -200
      }
    end

    it 'returns the correct HTTP status code' do
      put "/api/flights/#{flight.id}", params: invalid_params

      expect(response).to have_http_status(:bad_request)
    end

    it 'returns a correct error message' do
      put "/api/flights/#{flight.id}", params: invalid_params

      expect(json_response['errors']['base_price']).to include('must be greater than 0')
    end
  end
end

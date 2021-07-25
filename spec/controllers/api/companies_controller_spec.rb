RSpec.describe 'Companies API', type: :request do
  describe 'index action' do
    it 'returns the correct HTTP status code' do
      get '/api/companies'

      expect(response).to have_http_status(:ok)
    end

    it 'returns the correct number of records' do
      create_list(:company, 2)
      get '/api/companies'

      expect(json_response['companies'].size).to eq 2
    end
  end

  describe 'Show action' do
    let(:company) { create(:company) }

    it 'returns the correct HTTP status code' do
      get "/api/companies/#{company.id}"

      expect(response).to have_http_status(:ok)
    end

    it 'returns correct attributes' do
      get "/api/companies/#{company.id}"

      expect(json_response['company']).to include('name')
    end
  end

  describe 'Create action (valid params)' do
    let(:valid_params) do
      {
        name: 'Test Company'
      }
    end

    it 'returns the correct HTTP status code' do
      post '/api/companies', params: valid_params

      expect(response).to have_http_status(:created)
    end

    it 'returns correct attributes' do
      post '/api/companies', params: valid_params

      expect(json_response['company']).to include('name')
    end

    it 'creates a new record' do
      post '/api/companies', params: valid_params
      create_list(:company, 2)

      get '/api/companies'

      expect(json_response['companies'].size).to eq 3
    end
  end

  describe 'Create action (invalid params)' do
    it 'returns the correct HTTP status code' do
      post '/api/companies'

      expect(response).to have_http_status(:bad_request)
    end

    it 'returns a correct error message' do
      post '/api/companies'

      expect(json_response['errors']['name']).to include("can't be blank")
    end
  end

  describe 'Update action (valid params)' do
    let(:company) { create(:company) }
    let(:valid_params) do
      {
        name: 'New company'
      }
    end

    it 'returns the correct HTTP status code' do
      put "/api/companies/#{company.id}", params: valid_params

      expect(response).to have_http_status(:ok)
    end

    it 'returns the correct attributes' do
      put "/api/companies/#{company.id}", params: valid_params

      expect(json_response['company']).to include('name')
    end

    it 'correctly updates data' do
      put "/api/companies/#{company.id}", params: valid_params

      get "/api/companies/#{company.id}"

      expect(json_response['company']['name']).to include('New company')
    end
  end

  describe 'Update action (invalid params)' do
    let(:company) { create(:company) }
    let(:company2) { create(:company) }
    let(:invalid_params) do
      {
        name: company2.name
      }
    end

    it 'returns the correct HTTP status code' do
      put "/api/companies/#{company.id}", params: invalid_params

      expect(response).to have_http_status(:bad_request)
    end

    it 'returns a correct error message' do
      put "/api/companies/#{company.id}", params: invalid_params

      expect(json_response['errors']['name']).to include('has already been taken')
    end
  end
end

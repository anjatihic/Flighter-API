RSpec.describe 'Users API', type: :request do
  describe 'index action' do
    it 'returns the correct HTTP status code' do
      get '/api/users'

      expect(response).to have_http_status(:ok)
    end

    it 'returns the correct number of records' do
      create_list(:user, 3)
      get '/api/users'

      expect(json_response['users'].size).to eq 3
    end
  end

  describe 'Show action' do
    let(:user) { create(:user) }

    it 'returns the correct HTTP status code' do
      get "/api/users/#{user.id}"

      expect(response).to have_http_status(:ok)
    end

    it 'returns correct attributes' do
      get "/api/users/#{user.id}"

      expect(json_response['user']).to include('first_name')
      expect(json_response['user']).to include('last_name')
      expect(json_response['user']).to include('email')
    end
  end

  describe 'Create action (valid params)' do
    let(:valid_params) do
      {
        user:
        {
          first_name: 'Jane',
          last_name: 'Doe',
          email: 'email@email.com'
        }
      }
    end

    it 'returns the correct HTTP status code' do
      post '/api/users', params: valid_params

      expect(response).to have_http_status(:created)
    end

    it 'returns correct attributes' do
      post '/api/users', params: valid_params

      expect(json_response['user']).to include('first_name')
      expect(json_response['user']).to include('last_name')
      expect(json_response['user']).to include('email')
    end

    it 'creates a new record' do
      post '/api/users', params: valid_params
      create_list(:user, 2)

      get '/api/users'

      expect(json_response['users'].size).to eq 3
    end
  end

  describe 'Create action (invalid params)' do
    let(:invalid_params) do
      {
        user:
        {
          first_name: 'John',
          last_name: 'Doe'
        }
      }
    end

    it 'returns the correct HTTP status code' do
      post '/api/users', params: invalid_params

      expect(response).to have_http_status(:bad_request)
    end

    it 'returns a correct error message' do
      post '/api/users', params: invalid_params

      expect(json_response['errors']['email']).to include("can't be blank")
    end
  end

  describe 'Update action (valid params)' do
    let(:user) { create(:user) }
    let(:valid_params) do
      {
        user: { first_name: 'Jane' }
      }
    end

    it 'returns the correct HTTP status code' do
      put "/api/users/#{user.id}", params: valid_params

      expect(response).to have_http_status(:ok)
    end

    it 'returns the correct attributes' do
      put "/api/users/#{user.id}", params: valid_params

      expect(json_response['user']).to include('first_name')
      expect(json_response['user']).to include('last_name')
      expect(json_response['user']).to include('email')
    end

    it 'correctly updates data' do
      put "/api/users/#{user.id}", params: valid_params

      get "/api/users/#{user.id}"

      expect(json_response['user']['first_name']).to include('Jane')
    end
  end

  describe 'Update action (invalid params)' do
    let(:user) { create(:user) }
    let(:user2) { create(:user) }
    let(:invalid_params) do
      {
        user: { email: user2.email }
      }
    end

    it 'returns the correct HTTP status code' do
      put "/api/users/#{user.id}", params: invalid_params

      expect(response).to have_http_status(:bad_request)
    end

    it 'returns a correct error message' do
      put "/api/users/#{user.id}", params: invalid_params

      expect(json_response['errors']['email']).to include('has already been taken')
    end
  end
end

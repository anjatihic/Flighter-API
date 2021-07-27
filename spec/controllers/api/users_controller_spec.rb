RSpec.describe 'Users API', type: :request do
  let(:request_headers) do
    {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }
  end

  describe 'GET /api/users, #index' do
    it 'returns the correct HTTP status code' do
      get '/api/users', headers: request_headers

      expect(response).to have_http_status(:ok)
    end

    it 'returns the correct number of records' do
      create_list(:user, 3)
      get '/api/users', headers: request_headers

      expect(json_response['users'].size).to eq 3
    end

    it 'returns an empty json hash when no records in database' do
      get '/api/users', headers: request_headers

      expect(json_response['users'].size).to eq 0
    end
  end

  describe 'GET /api/users/:id, #show' do
    let(:user) { create(:user) }

    it 'returns the correct HTTP status code' do
      get "/api/users/#{user.id}", headers: request_headers

      expect(response).to have_http_status(:ok)
    end

    it 'returns correct attributes' do
      get "/api/users/#{user.id}", headers: request_headers

      expect(json_response['user']).to include('first_name')
      expect(json_response['user']).to include('last_name')
      expect(json_response['user']).to include('email')
    end

    it 'returns error when user not found' do
      get "/api/users/#{user.id + 1}", headers: request_headers

      expect(json_response).to include('errors')
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/users, #create' do
    context 'with valid params' do
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
        post '/api/users', params: valid_params.to_json,
                           headers: request_headers

        expect(response).to have_http_status(:created)
      end

      it 'returns correct attributes' do
        post '/api/users', params: valid_params.to_json,
                           headers: request_headers

        expect(json_response['user']).to include('first_name')
        expect(json_response['user']).to include('last_name')
        expect(json_response['user']).to include('email')
      end

      it 'creates a new record' do
        expect do
          post '/api/users', params: valid_params.to_json,
                             headers: request_headers
        end.to change(User, :count).by(1)
      end
    end

    context 'with invalid params' do
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
        post '/api/users', params: invalid_params.to_json,
                           headers: request_headers

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a correct error message' do
        post '/api/users', params: invalid_params.to_json,
                           headers: request_headers

        expect(json_response['errors']['email']).to include("can't be blank")
      end

      it "doesn't create a new record" do
        expect do
          post '/api/users', params: invalid_params.to_json,
                             headers: request_headers
        end.to change(User, :count).by(0)
      end
    end
  end

  describe 'PUT /api/users, #update' do
    context 'with valid params' do
      let(:user) { create(:user) }
      let(:valid_params) do
        {
          user: { first_name: 'Jane' }
        }
      end

      it 'returns the correct HTTP status code' do
        put "/api/users/#{user.id}", params: valid_params.to_json,
                                     headers: request_headers

        expect(response).to have_http_status(:ok)
      end

      it 'returns the correct attributes' do
        put "/api/users/#{user.id}", params: valid_params.to_json,
                                     headers: request_headers

        expect(json_response['user']).to include('first_name')
        expect(json_response['user']).to include('last_name')
        expect(json_response['user']).to include('email')
      end

      it 'correctly updates data' do
        put "/api/users/#{user.id}", params: valid_params.to_json,
                                     headers: request_headers

        expect(User.find(user.id).first_name).to include(user.reload.first_name)
      end
    end

    context 'with invalid params' do
      let(:user) { create(:user) }
      let(:user2) { create(:user) }
      let(:invalid_params) do
        {
          user: { email: user2.email }
        }
      end

      it 'returns the correct HTTP status code' do
        put "/api/users/#{user.id}", params: invalid_params.to_json,
                                     headers: request_headers

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a correct error message' do
        put "/api/users/#{user.id}", params: invalid_params.to_json,
                                     headers: request_headers

        expect(json_response['errors']['email']).to include('has already been taken')
        expect(User.find(user.id).email).to include(user.email)
      end
    end
  end

  describe 'DELETE /api/bookings/:id, #destroy' do
    let(:user) { create(:user) }

    it 'removes a user from database' do
      delete "/api/users/#{user.id}", headers: request_headers

      expect(User.find_by(id: user.id)).to eq nil
    end

    it 'returns a correct HTTP status code' do
      delete "/api/users/#{user.id}", headers: request_headers

      expect(response).to have_http_status(:no_content)
    end
  end
end

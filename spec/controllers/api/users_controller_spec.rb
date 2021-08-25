# rubocop:disable RSpec/NestedGroups, RSpec/MultipleMemoizedHelpers

RSpec.describe 'Users API', type: :request do
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

  let!(:admin_user) { create(:user, token: 'admin', role: 'admin') }

  describe 'GET /api/users, #index' do
    context 'when unauthenticated' do
      it 'returns the correct HTTP status code' do
        get '/api/users', headers: no_token_request_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      context 'when authorized' do
        it 'returns the correct HTTP status code' do
          get '/api/users', headers: admin_request_headers

          expect(response).to have_http_status(:ok)
        end

        it 'returns the correct number of records' do
          get '/api/users', headers: admin_request_headers

          expect(json_response['users'].size).to eq 1
        end
      end

      context 'when unauthorized' do
        it 'returns the correct HTTP status code' do
          create(:user, token: 'abc')

          get '/api/users', headers: request_headers

          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end

  describe 'GET /api/users/:id, #show' do
    context 'when unauthenticated' do
      let(:unauthenticated_user) { create(:user) }

      it 'returns the correct HTTP status' do
        get "/api/users/#{unauthenticated_user.id}", headers: no_token_request_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      let(:authenticated_user) { create(:user, token: 'abc') }

      context 'when unauthorized in valid scenarios' do
        it 'returns the correct HTTP status code' do
          get "/api/users/#{authenticated_user.id}", headers: request_headers

          expect(response).to have_http_status(:ok)
        end

        it 'returns correct attributes' do
          get "/api/users/#{authenticated_user.id}", headers: request_headers

          expect(json_response['user']).to include('first_name')
          expect(json_response['user']).to include('last_name')
          expect(json_response['user']).to include('email')
          expect(json_response['user']).to include('role')
        end
      end

      context 'when unauthorized in invalid scenarios' do
        it 'returns the correct HTTP status code' do
          get "/api/users/#{admin_user.id}", headers: request_headers

          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'when authorized' do
        it 'returns the correct HTTP status code' do
          get "/api/users/#{authenticated_user.id}", headers: admin_request_headers

          expect(response).to have_http_status(:ok)
        end

        it 'returns correct attributes' do
          user = create(:user)
          get "/api/users/#{user.id}", headers: admin_request_headers

          expect(json_response['user']).to include('first_name')
          expect(json_response['user']).to include('last_name')
          expect(json_response['user']).to include('email')
          expect(json_response['user']).to include('role')
        end

        it 'returns error when record not found' do
          get "/api/users/#{admin_user.id + 1}", headers: admin_request_headers

          expect(json_response).to include('errors')
          expect(response).to have_http_status(:not_found)
        end
      end
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
            email: 'email@email.com',
            password: 'pass'
          }
        }
      end

      it 'returns the correct HTTP status code' do
        post '/api/users', params: valid_params.to_json,
                           headers: no_token_request_headers

        expect(response).to have_http_status(:created)
      end

      it 'returns correct attributes' do
        post '/api/users', params: valid_params.to_json,
                           headers: no_token_request_headers

        expect(json_response['user']).to include('first_name')
        expect(json_response['user']).to include('last_name')
        expect(json_response['user']).to include('email')
      end

      it 'creates a new record' do
        expect do
          post '/api/users', params: valid_params.to_json,
                             headers: no_token_request_headers
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
                           headers: no_token_request_headers

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error message' do
        post '/api/users', params: invalid_params.to_json,
                           headers: no_token_request_headers

        expect(json_response).to include('errors')
      end

      it "doesn't create a new record" do
        expect do
          post '/api/users', params: invalid_params.to_json,
                             headers: no_token_request_headers
        end.to change(User, :count).by(0)
      end
    end
  end

  describe 'PUT /api/users, #update' do
    context 'when unauthenticated' do
      let(:unauthenticated_user) { create(:user) }
      let(:update_params) do
        {
          user: { email: 'newemail@email.com' }
        }
      end

      it 'returns the correct HTTP status' do
        put "/api/users/#{unauthenticated_user.id}", params: update_params.to_json,
                                                     headers: no_token_request_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      let(:authenticated_user) { create(:user, token: 'abc') }

      context 'with valid params' do
        let(:valid_params) do
          {
            user: { first_name: 'Jane' }
          }
        end

        it 'returns the correct HTTP status code' do
          put "/api/users/#{authenticated_user.id}", params: valid_params.to_json,
                                                     headers: request_headers

          expect(response).to have_http_status(:ok)
        end

        it 'returns correct attributes' do
          put "/api/users/#{authenticated_user.id}", params: valid_params.to_json,
                                                     headers: request_headers

          expect(json_response['user']).to include('first_name')
          expect(json_response['user']).to include('last_name')
          expect(json_response['user']).to include('email')
          expect(json_response['user']).to include('role')
        end

        it 'correctly updates data' do
          put "/api/users/#{authenticated_user.id}", params: valid_params.to_json,
                                                     headers: request_headers

          expect(authenticated_user.reload.first_name).to include(valid_params[:user][:first_name])
        end
      end

      context 'with invalid params' do
        let(:invalid_params) do
          {
            user: { email: '' }
          }
        end

        it 'returns the correct HTTP status code' do
          put "/api/users/#{authenticated_user.id}", params: invalid_params.to_json,
                                                     headers: request_headers

          expect(response).to have_http_status(:bad_request)
        end

        it 'returns an error message' do
          put "/api/users/#{authenticated_user.id}", params: invalid_params.to_json,
                                                     headers: request_headers

          expect(json_response).to include('errors')
        end

        it "doesn't save the invalid params" do
          put "/api/users/#{authenticated_user.id}", params: invalid_params.to_json,
                                                     headers: request_headers

          expect(User.find(authenticated_user.id).email).to include(authenticated_user.email)
        end
      end
    end

    context 'when authorized' do
      context 'with valid params' do
        let(:valid_params) do
          {
            user: { first_name: 'Jane' }
          }
        end
        let(:user) { create(:user) }

        it 'returns the correct HTTP status code' do
          put "/api/users/#{user.id}", params: valid_params.to_json,
                                       headers: admin_request_headers

          expect(response).to have_http_status(:ok)
        end

        it 'returns correct attributes' do
          put "/api/users/#{user.id}", params: valid_params.to_json,
                                       headers: admin_request_headers

          expect(json_response['user']).to include('first_name')
          expect(json_response['user']).to include('last_name')
          expect(json_response['user']).to include('email')
          expect(json_response['user']).to include('role')
        end

        it 'correctly updates record' do
          put "/api/users/#{user.id}", params: valid_params.to_json,
                                       headers: admin_request_headers

          expect(User.find(user.id).first_name).to include(valid_params[:user][:first_name])
        end
      end

      context 'with invalid params' do
        let(:invalid_params) do
          {
            user: { email: '' }
          }
        end
        let(:user) { create(:user) }

        it 'returns the correct HTTP status code' do
          put "/api/users/#{user.id}", params: invalid_params.to_json,
                                       headers: admin_request_headers

          expect(response).to have_http_status(:bad_request)
        end

        it 'returns an error message' do
          put "/api/users/#{user.id}", params: invalid_params.to_json,
                                       headers: admin_request_headers

          expect(json_response).to include('errors')
        end

        it "doesn't save the invalid params" do
          put "/api/users/#{user.id}", params: invalid_params.to_json,
                                       headers: admin_request_headers

          expect(User.find(user.id).email).to include(user.email)
        end
      end
    end
  end

  describe 'DELETE /api/users/:id, #destroy' do
    context 'when unauthenticated' do
      let(:unauthenticated_user) { create(:user) }

      it 'returns the correct HTTP status' do
        put "/api/users/#{unauthenticated_user.id}", headers: no_token_request_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      let(:authenticated_user) { create(:user, token: 'abc') }

      context 'with valid params' do
        it 'returns the correct HTTP status code' do
          delete "/api/users/#{authenticated_user.id}", headers: request_headers

          expect(response).to have_http_status(:no_content)
        end

        it 'removes the record from database' do
          delete "/api/users/#{authenticated_user.id}", headers: request_headers

          expect(User.find_by(id: authenticated_user.id)).to eq nil
        end
      end

      context 'with invalid params' do
        it 'returns the correct HTTP status code' do
          delete "/api/users/#{admin_user.id}", headers: request_headers

          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'when authorized' do
      context 'with valid params' do
        let(:user) { create(:user) }

        it 'returns the correct HTTP status code' do
          delete "/api/users/#{user.id}", headers: admin_request_headers

          expect(response).to have_http_status(:no_content)
        end
      end

      context 'with invalid params' do
        let(:user) { create(:user) }

        it 'returns the correct HTTP status code' do
          delete "/api/users/#{user.id + 1}", headers: admin_request_headers

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups, RSpec/MultipleMemoizedHelpers

RSpec.describe 'Session API', type: :request do
  let!(:user) { create(:user, password: 'pass', token: 'abc') }
  let(:params) do
    {
      session:
      {
        email: user.email,
        password: 'pass'
      }
    }
  end
  let(:request_headers) do
    {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }
  end
  let(:request_headers_with_token) do
    {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'abc'
    }
  end

  describe 'POST /api/session, #create' do
    it 'returns the correct HTTP status code' do
      post '/api/session', params: params.to_json,
                           headers: request_headers

      expect(response).to have_http_status(:created)
    end

    it 'returns a session token' do
      post '/api/session', params: params.to_json,
                           headers: request_headers

      expect(json_response['session']).to include('token')
    end

    it 'returns error if params not valid' do
      invalid_params = { session: { email: user.email } }

      post '/api/session', params: invalid_params.to_json,
                           headers: request_headers

      expect(response).to have_http_status(:bad_request)
      expect(json_response['errors']['credentials']).to include('are invalid')
    end
  end

  describe 'DELETE /api/session, #destroy' do
    it 'returns the correct HTTP code status' do
      delete '/api/session', headers: request_headers_with_token

      expect(response).to have_http_status(:no_content)
    end

    it 'changes token' do
      original_token = user.token

      delete '/api/session', headers: request_headers_with_token

      expect(user.reload.token).not_to eq(original_token)
    end
  end
end

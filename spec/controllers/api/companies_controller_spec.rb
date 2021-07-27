RSpec.describe 'Companies API', type: :request do
  let(:request_headers) do
    {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }
  end

  describe 'GET /api/companies, #index' do
    it 'returns the correct HTTP status code' do
      get '/api/companies', headers: request_headers

      expect(response).to have_http_status(:ok)
    end

    it 'returns the correct number of records' do
      create_list(:company, 2)
      get '/api/companies', headers: request_headers

      expect(json_response['companies'].size).to eq 2
    end

    it 'returns an empty json hash when no records in database' do
      get '/api/companies', headers: request_headers

      expect(json_response['companies'].size).to eq 0
    end
  end

  describe 'GET /api/companies/:id, #show' do
    let(:company) { create(:company) }

    it 'returns the correct HTTP status code' do
      get "/api/companies/#{company.id}", headers: request_headers

      expect(response).to have_http_status(:ok)
    end

    it 'returns correct attributes' do
      get "/api/companies/#{company.id}", headers: request_headers

      expect(json_response['company']).to include('name')
    end

    it 'returns error when company not found' do
      get "/api/companies/#{company.id + 1}", headers: request_headers

      expect(json_response).to include('errors')
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/companies, #create' do
    context 'with valid params' do
      let(:valid_params) do
        {
          company: { name: 'Test Company' }
        }
      end

      it 'returns the correct HTTP status code' do
        post '/api/companies', params: valid_params.to_json,
                               headers: request_headers

        expect(response).to have_http_status(:created)
      end

      it 'returns correct attributes' do
        post '/api/companies', params: valid_params.to_json,
                               headers: request_headers

        expect(json_response['company']).to include('name')
      end

      it 'creates a new record' do
        expect do
          post '/api/companies', params: valid_params.to_json,
                                 headers: request_headers
        end.to change(Company, :count).by(1)
      end
    end

    context 'with invalid params' do
      let(:company) { create(:company) }
      let(:invalid_params) do
        {
          company:
          {
            name: company.name
          }
        }
      end

      it 'returns the correct HTTP status code' do
        post '/api/companies', params: invalid_params.to_json,
                               headers: request_headers

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a correct error message' do
        post '/api/companies', params: invalid_params.to_json,
                               headers: request_headers

        expect(json_response['errors']['name']).to include('has already been taken')
      end

      it "doesn't create a new record" do
        expect do
          post '/api/companies', params: invalid_params.to_json,
                                 headers: request_headers
        end.to change(Company, :count).by(1) # it makes 1 record before request with invalid params
      end
    end
  end

  describe 'PUT /api/companies, #update' do
    context 'with valid params' do
      let(:company) { create(:company) }
      let(:valid_params) do
        {
          company: { name: 'New company' }
        }
      end

      it 'returns the correct HTTP status code' do
        put "/api/companies/#{company.id}", params: valid_params.to_json,
                                            headers: request_headers

        expect(response).to have_http_status(:ok)
      end

      it 'returns the correct attributes' do
        put "/api/companies/#{company.id}", params: valid_params.to_json,
                                            headers: request_headers

        expect(json_response['company']).to include('name')
      end

      it 'correctly updates data' do
        put "/api/companies/#{company.id}", params: valid_params.to_json,
                                            headers: request_headers

        expect(company.reload.name).to include(valid_params[:company][:name])
      end
    end

    context 'with invalid params' do
      let(:company) { create(:company) }
      let(:company2) { create(:company) }
      let(:invalid_params) do
        {
          company: { name: company2.name }
        }
      end

      it 'returns the correct HTTP status code' do
        put "/api/companies/#{company.id}", params: invalid_params.to_json,
                                            headers: request_headers

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a correct error message' do
        put "/api/companies/#{company.id}", params: invalid_params.to_json,
                                            headers: request_headers

        expect(json_response['errors']['name']).to include('has already been taken')
        expect(Company.find(company.id).name).to include(company.name)
      end
    end
  end

  describe 'DELETE /api/bookings/:id, #destroy' do
    let(:company) { create(:company) }

    it 'removes a company from database' do
      delete "/api/companies/#{company.id}", headers: request_headers
      expect(Company.find_by(id: company.id)).to eq nil
    end

    it 'returns a correct HTTP status code' do
      delete "/api/companies/#{company.id}", headers: request_headers

      expect(response).to have_http_status(:no_content)
    end
  end
end

# rubocop:disable RSpec/NestedGroups, RSpec/MultipleMemoizedHelpers
RSpec.describe 'Companies API', type: :request do
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

  describe 'GET /api/companies, #index' do
    it 'returns the correct HTTP status code' do
      get '/api/companies', headers: no_token_request_headers

      expect(response).to have_http_status(:ok)
    end

    it 'returns the correct number of records' do
      create_list(:company, 2)
      get '/api/companies', headers: no_token_request_headers

      expect(json_response['companies'].size).to eq 2
    end

    it 'returns an empty json hash when no records in database' do
      get '/api/companies', headers: no_token_request_headers

      expect(json_response['companies'].size).to eq 0
    end

    it 'orders companies by name ASC' do
      first_company = create(:company, name: 'A-Company')
      third_company = create(:company, name: 'C-Company')
      second_company = create(:company, name: 'B-Company')

      expected_order = [first_company.name, second_company.name, third_company.name]

      get '/api/companies', headers: no_token_request_headers

      companies_names = json_response['companies'].map { |company| company['name'] }

      expect(companies_names).to eq expected_order
    end

    it 'returns only companies with active flights if filter=active added' do
      new_company = create(:company)
      create(:flight, company: new_company)
      create_list(:company, 2)

      get '/api/companies?filter=active', headers: no_token_request_headers

      expect(json_response['companies'].size).to eq 1
    end
  end

  describe 'GET /api/companies, #show' do
    let(:company) { create(:company) }

    it 'returns the correct HTTP status code' do
      get "/api/companies/#{company.id}", headers: no_token_request_headers

      expect(response).to have_http_status(:ok)
    end

    it 'returns correct attributes' do
      get "/api/companies/#{company.id}", headers: no_token_request_headers

      expect(json_response['company']).to include('name')
    end

    it 'returns error when company not found' do
      get "/api/companies/#{company.id + 1}", headers: no_token_request_headers

      expect(json_response).to include('errors')
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/companies, #create' do
    context 'when unauthenticated' do
      let(:create_params) do
        {
          company: { name: 'Company name' }
        }
      end

      it 'returns the correct HTTP status code' do
        post '/api/companies', params: create_params.to_json,
                               headers: no_token_request_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      let(:create_params) do
        {
          company: { name: 'Company name' }
        }
      end
      let(:user) { create(:user, token: 'abc') }

      it 'returns the correct HTTP status code' do
        post '/api/companies', params: create_params.to_json,
                               headers: request_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authorized' do
      context 'with valid params' do
        let(:valid_params) do
          {
            company: { name: 'Company name' }
          }
        end

        it 'returns the correct HTTP status code' do
          post '/api/companies', params: valid_params.to_json,
                                 headers: admin_request_headers

          expect(response).to have_http_status(:created)
        end

        it 'returns the correct attributes' do
          post '/api/companies', params: valid_params.to_json,
                                 headers: admin_request_headers

          expect(json_response['company']).to include('name')
        end

        it 'creates a new record' do
          expect do
            post '/api/companies', params: valid_params.to_json,
                                   headers: admin_request_headers
          end.to change(Company, :count).by(1)
        end
      end

      context 'with invalid params' do
        let(:invalid_params) do
          {
            company: { name: '' }
          }
        end

        it 'returns the correct HTTP status code' do
          post '/api/companies', params: invalid_params.to_json,
                                 headers: admin_request_headers

          expect(response).to have_http_status(:bad_request)
        end

        it 'returns an error message' do
          post '/api/companies', params: invalid_params.to_json,
                                 headers: admin_request_headers

          expect(json_response).to include('errors')
        end

        it "doesn't create a new record" do
          expect do
            post '/api/companies', params: invalid_params.to_json,
                                   headers: admin_request_headers
          end.not_to change(User, :count)
        end
      end
    end
  end

  describe 'PUT /api/companies/:id, #update' do
    context 'when unauthenticated' do
      let(:update_params) do
        {
          company: { name: 'Company name' }
        }
      end
      let(:company) { create(:company) }

      it 'returns the correct HTTP status code' do
        put "/api/companies/#{company.id}", params: update_params.to_json,
                                            headers: no_token_request_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authorized' do
      context 'with valid params' do
        let(:valid_params) do
          {
            company: { name: 'Company name' }
          }
        end
        let(:company) { create(:company) }

        it 'returns the correct HTTP status code' do
          put "/api/companies/#{company.id}", params: valid_params.to_json,
                                              headers: admin_request_headers

          expect(response).to have_http_status(:ok)
        end

        it 'returns the correct attributes' do
          put "/api/companies/#{company.id}", params: valid_params.to_json,
                                              headers: admin_request_headers

          expect(json_response['company']).to include('name')
        end

        it 'correctly updates data' do
          put "/api/companies/#{company.id}", params: valid_params.to_json,
                                              headers: admin_request_headers

          expect(company.reload.name).to include(valid_params[:company][:name])
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

  describe 'DELETE /api/companies/:id, #destroy' do
    let(:company) { create(:company) }

    context 'when unauthenticated' do
      it 'returns the correct HTTP status code' do
        delete "/api/companies/#{company.id}", headers: no_token_request_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      it 'returns the correct HTTP status code' do
        delete "/api/companies/#{company.id}", headers: request_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authorized' do
      context 'with valid params' do
        it 'returns the correct HTTP status code' do
          delete "/api/companies/#{company.id}", headers: admin_request_headers

          expect(response).to have_http_status(:no_content)
        end

        it 'removes the record from database' do
          delete "/api/companies/#{company.id}", headers: admin_request_headers

          expect(Company.find_by(id: company.id)).to eq nil
        end
      end

      context 'with invalid params' do
        it 'returns the correct HTTP status code' do
          delete "/api/companies/#{company.id + 1}", headers: admin_request_headers

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups, RSpec/MultipleMemoizedHelpers

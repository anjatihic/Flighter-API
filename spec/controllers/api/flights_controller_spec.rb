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

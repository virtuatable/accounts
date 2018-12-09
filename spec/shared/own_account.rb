RSpec.shared_examples 'GET /own' do
  describe 'GET /accounts/own' do

    let!(:session) { create(:session, account: account) }

    describe 'Nominal case' do
      before do
        get "/accounts/own?session_id=#{session.token}&token=test_token&app_key=test_key"
      end
      it 'Returns a OK (200) status' do
        expect(last_response.status).to be 200
      end
      describe 'Account attributes' do
        let!(:parsed_account) { JSON.parse(last_response.body)['account'] }

        it 'Has an ID' do
          expect(parsed_account['id']).to eq account.id.to_s
        end
        it 'Has a username' do
          expect(parsed_account['username']).to eq(account.username)
        end
        it 'Has an email' do
          expect(parsed_account['email']).to eq(account.email)
        end
        it 'Has a firstname' do
          expect(parsed_account['firstname']).to eq(account.firstname)
        end
        it 'Has a lastname' do
          expect(parsed_account['lastname']).to eq(account.lastname)
        end
      end
    end

    it_should_behave_like 'a route', 'get', '/accounts/own'

    describe '400 errors' do
      describe 'session ID not given' do
        before do
          get "/accounts/own?token=test_token&app_key=test_key"
        end
        it 'Raises a 400 error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'session_id',
            'error' => 'required'
          })
        end
      end
    end

    describe '404 errors' do
      describe 'Session ID not found' do
        before do
          get "/accounts/own?session_id=unknown_token&token=test_token&app_key=test_key"
        end
        it 'Raises a 404 error' do
          expect(last_response.status).to be 404
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 404,
            'field' => 'session_id',
            'error' => 'unknown'
          })
        end
      end
    end
  end
end
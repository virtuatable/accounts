RSpec.shared_examples 'GET /own' do
  describe 'GET /accounts/own' do

    let!(:session) { create(:session, account: account) }

    describe 'Nominal case' do
      before do
        get '/accounts/own', {
          session_id: session.token,
          token: 'test_token',
          app_key: 'test_key'
        }
      end
      it 'Returns a OK (200) status' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body' do
        expect(last_response.body).to include_json(
          id: account.id.to_s,
          username: account.username,
          email: account.email,
          firstname: account.firstname,
          lastname: account.lastname
        )
      end
    end

    it_should_behave_like 'a route', 'get', '/accounts/own'

    describe '400 errors' do
      describe 'session ID not given' do
        before do
          get '/accounts/own', {
            token: 'test_token',
            app_key: 'test_key'
          }
        end
        it 'Raises a 400 error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json(
            status: 400,
            field: 'session_id',
            error: 'required'
          )
        end
      end
    end

    describe '404 errors' do
      describe 'Session ID not found' do
        before do
          get '/accounts/own', {
            session_id: 'unknown_token',
            token: 'test_token',
            app_key: 'test_key'
          }
        end
        it 'Raises a 404 error' do
          expect(last_response.status).to be 404
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json(
            status: 404,
            field: 'session_id',
            error: 'unknown'
          )
        end
      end
    end
  end
end
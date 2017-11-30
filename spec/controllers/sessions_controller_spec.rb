RSpec.describe SessionsController do
  describe 'post /sessions' do

    def app; SessionsController.new; end

    after do
      DatabaseCleaner.clean
    end

    before do
      @account = Arkaan::Account.create!(username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test@test.com')
      @gateway = Arkaan::Monitoring::Gateway.create!(url: 'https://gateway.test.com', token: 'test_token')
      @application = Arkaan::OAuth::Application.create!(name: 'Test app', key: 'test_key', premium: true, creator: @account)
      @unauthorized = Arkaan::OAuth::Application.create!(name: 'Other test app', key: 'other_key', premium: false, creator: @account)
    end

    describe 'nominal case' do
      before do
        post '/', {token: 'test_token', username: 'Babausse', password: 'password', app_key: 'test_key'}.to_json
      end
      it 'Correctly creates a session when every parameter are alright' do
        expect(last_response.status).to be 201
      end
      it 'returns the correct response if the session is successfully created' do
        session = Arkaan::Authentication::Session.first
        expect(JSON.parse(last_response.body)).to eq({'token' => session.token, 'expiration' => session.expiration})
      end
    end
    describe 'bad request errors' do
      describe 'empty body error' do
        before do
          post '/'
        end
        it 'Raises a bad request (400) error when the body is empty' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the body is empty' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no token error' do
        before do
          post '/', {username: 'Babausse', password: 'password', app_key: 'test_key'}.to_json
        end
        it 'Raises a bad request (400) error when the body doesn\'t contain the token of the gateway' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the body does not contain a gateway token' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no username error' do
        before do
          post '/', {token: 'test_token', password: 'password', app_key: 'test_key'}.to_json
        end
        it 'Raises a bad request (400) error when the body doesn\'t contain the username' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the body does not contain a username' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no password error' do
        before do
          post '/', {token: 'test_token', username: 'Babausse', app_key: 'test_key'}.to_json
        end
        it 'Raises a bad request (400) error when the body doesn\'t contain the password' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the body does not contain a password' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no app key error' do
        before do
          post '/', {token: 'test_token', username: 'Babausse', password: 'password'}.to_json
        end
        it 'Raises a bad request (400) error when the body doesn\'t contain the token of the gateway' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the body does not contain a gateway token' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
    end
    describe 'unauthorized errors' do
      describe 'non premium application access' do
        before do
          post '/', {token: 'test_token', username: 'Babausse', password: 'password', app_key: 'other_key'}.to_json
        end
        it 'raises a unauthorized (401) error when the given API key belongs to a non premium application' do
          expect(last_response.status).to be 401
        end
        it 'returns the correct body when application is not authorized to access the service' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'application_not_authorized'})
        end
      end
    end
    describe 'forbidden errors' do
      describe 'wrong password given' do
        before do
          post '/', {token: 'test_token', username: 'Babausse', password: 'other_password', app_key: 'test_key'}.to_json
        end
        it 'raises a forbidden (403) error when the given password doesn\'t match the user password' do
          expect(last_response.status).to be 403
        end
        it 'returns the correct body when the password given does not match the user password' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'wrong_password'})
        end
      end
    end
    describe 'not found errors' do
      describe 'application not found' do
        before do
          post '/', {token: 'test_token', username: 'Babausse', password: 'password', app_key: 'another_key'}.to_json
        end
        it 'Raises a not found (404) error when the key doesn\'t belong to any application' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'application_not_found'})
        end
      end
      describe 'gateway not found' do
        before do
          post '/', {token: 'other_token', username: 'Babausse', password: 'other_password', app_key: 'test_key'}.to_json
        end
        it 'Raises a not found (404) error when the key doesn\'t belong to any application' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'gateway_not_found'})
        end
      end
      describe 'username not found' do
        before do
          post '/', {token: 'test_token', username: 'Another Username', password: 'other_password', app_key: 'test_key'}.to_json
        end
        it 'Raises a not found (404) error when the username doesn\'t belong to any known user' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body if the username is not belonging to any user' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'account_not_found'})
        end
      end
    end
  end
end
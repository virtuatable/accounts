RSpec.describe AccountsController do

  def app
    AccountsController.new
  end

  let!(:account) { create(:account) }
  let!(:gateway) { create(:gateway) }
  let!(:premium_application) { create(:premium_application, creator: account) }
  let!(:application) { create(:application, creator: account) }

  describe 'post /accounts' do
    describe 'nominal case' do
      before do
        post '/', {
          token: 'test_token',
          app_key: 'test_key',
          username: 'Babausse',
          password: 'password',
          password_confirmation: 'password',
          email: 'test@test.com',
          firstname: 'Vincent',
          lastname: 'Courtois',
          birthdate: DateTime.new(1989, 8, 29, 21, 50)
        }.to_json
      end
      it 'returns a Created (201) code when an account is correctly created' do
        expect(last_response.status).to be 201
      end
      it 'correctly creates an account when all the informations are being given' do
        expect(JSON.parse(last_response.body)['message']).to eq('created')
      end
      describe 'Accounts attributes' do
        let!(:attributes) { JSON.parse(last_response.body)['account'] }

        it 'creates an account with the correct username' do
          expect(attributes['username']).to eq('Babausse')
        end
        it 'creates an account with the correct email address' do
          expect(attributes['email']).to eq('test@test.com')
        end
        it 'creates an account with the correct last name' do
          expect(attributes['lastname']).to eq('Courtois')
        end
        it 'creates an account with the correct first name' do
          expect(attributes['firstname']).to eq('Vincent')
        end
        it 'creates an account with the correct birth date' do
          expect(DateTime.parse(attributes['birthdate'])).to eq(DateTime.new(1989, 8, 29, 21, 50))
        end
      end
    end
    describe 'bad request errors' do
      describe 'empty body error' do
        before do
          post '/'
        end
        it 'Raises a Bad Request (400) error when the body is empty' do
          expect(last_response.status).to be 400
        end
        it 'returns a correct body when the body of the request was empty' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no token error' do
        before do
          post '/', {app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a Bad Request (400) error when the gateway token is not given' do
          expect(last_response.status).to be 400
        end
        it 'returns a correct body when the gateway token is not given' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no app key error' do
        before do
          post '/', {token: 'test_token', username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a Bad Request (400) error when the application key is not given' do
          expect(last_response.status).to be 400
        end
        it 'returns a correct body when the application key is not given' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no username error' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a Bad Request (400) error when the username is not given' do
          expect(last_response.status).to be 400
        end
        it 'returns a correct body when the username is not given' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no password error' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a Bad Request (400) error when the password is not given' do
          expect(last_response.status).to be 400
        end
        it 'returns a correct body when the password is not given' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no password confirmation error' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a Bad Request (400) error when the password confirmation is not given' do
          expect(last_response.status).to be 400
        end
        it 'returns a correct body when the password confirmation is not given' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no email error' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'password'}.to_json
        end
        it 'Raises a Bad Request (400) error when the email is not given' do
          expect(last_response.status).to be 400
        end
        it 'returns a correct body when the email is not given' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
    end
    describe 'unauthorized errors' do
      describe 'not premium application' do
        before do
          post '/', {token: 'test_token', app_key: 'other_key', username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises an Unauthorized (401) error when the application issuing the request is not premium' do
          expect(last_response.status).to be 401
        end
        it 'returns a correct body when the application is not premium' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'application_not_authorized'})
        end
      end
    end
    describe 'not found errors' do
      describe 'application not found' do
        before do
          post '/', {token: 'test_token', app_key: 'fake_key', username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
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
          post '/', {token: 'fake_token', app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a not found (404) error when the key doesn\'t belong to any application' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'gateway_not_found'})
        end
      end
    end
    describe 'unprocessable entity errors' do
      describe 'already taken username error' do
        before do
          create(:account, username: 'Babausse', email: 'another@test.com')
          post '/', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises an Unprocessable Entity (422) error when the username is already taken' do
          expect(last_response.status).to be 422
        end
        it 'returns a correct body is the username is already taken' do
          expect(JSON.parse(last_response.body)['errors']).to eq(['account.username.uniq'])
        end
      end
      describe 'too short username error' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', username: 'test', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises an Unprocessable Entity (422) error when the username is too short' do
          expect(last_response.status).to be 422
        end
        it 'returns a correct body when the username is too short' do
          expect(JSON.parse(last_response.body)['errors']).to eq(['account.username.short'])
        end
      end
      describe 'already taken email error' do
        before do
          create(:account, username: 'Another random username', email: 'test@test.com')
          post '/', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises an Unprocessable Entity (422) error when the email is already taken' do
          expect(last_response.status).to be 422
        end
        it 'returns a correct body when the email is already taken' do
          expect(JSON.parse(last_response.body)['errors']).to eq(['account.email.uniq'])
        end
      end
      describe 'bad format email error' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test'}.to_json
        end
        it 'Raises an Unprocessable Entity (422) error when the email has a wrong format' do
          expect(last_response.status).to be 422
        end
        it 'returns a correct body when the email has a wrong format' do
          expect(JSON.parse(last_response.body)['errors']).to eq(['account.email.format'])
        end
      end
      describe 'password confirmation not matching error' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'another password', email: 'test@test.com'}.to_json
        end
        it 'Raises an Unprocessable Entity (422) error when the password confirmation does not match the password' do
          expect(last_response.status).to be 422
        end
        it 'returns a correct body when the password confirmation does not match the password' do
          expect(JSON.parse(last_response.body)['errors']).to eq(['account.password.confirmation'])
        end
      end
    end
  end

  describe 'get /accounts/:id' do
    describe 'Nominal case' do
      before do
        get "/#{account.id.to_s}?token=test_token&app_key=test_key"
      end
      it 'Returns an OK (200) response when the account exists' do
        expect(last_response.status).to be 200
      end
      describe 'Account attributes' do
        let!(:parsed_account) { JSON.parse(last_response.body)['account'] }

        it 'Returns an account with the correct username' do
          expect(parsed_account['username']).to eq(account.username)
        end
        it 'Returns an account with the correct email' do
          expect(parsed_account['email']).to eq(account.email)
        end
        it 'Returns an account with the correct first name' do
          expect(parsed_account['firstname']).to eq(account.firstname)
        end
        it 'Returns an account with the correct last name' do
          expect(parsed_account['lastname']).to eq(account.lastname)
        end
        it 'Returns an account with the correct birthdate' do
          expect(DateTime.parse(parsed_account['birthdate'])).to eq(account.birthdate)
        end
      end
    end
    describe 'bad request errors' do
      describe 'no token error' do
        before do
          get "#{account.id.to_s}?app_key=test_key"
        end
        it 'Raises a Bad Request (400) error when the gateway token is not given' do
          expect(last_response.status).to be 400
        end
        it 'returns a correct body when the gateway token is not given' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no app key error' do
        before do
          get "#{account.id.to_s}?token=test_token"
        end
        it 'Raises a Bad Request (400) error when the application key is not given' do
          expect(last_response.status).to be 400
        end
        it 'returns a correct body when the application key is not given' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
    end
    describe 'not found errors' do
      describe 'application not found' do
        before do
          get "#{account.id.to_s}?token=test_token&app_key=fake_key"
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
          get "#{account.id.to_s}?token=fake_token&app_key=test_key"
        end
        it 'Raises a not found (404) error when the key doesn\'t belong to any application' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'gateway_not_found'})
        end
      end
      describe 'account not found' do
        before do
          get "unexisting_id?token=test_token&app_key=test_key"
        end
        it 'Returns a Not Found (404) error when the account does not exist' do
          expect(last_response.status).to be 404
        end
        it 'Returns the correct message when an account does not exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'account_not_found'})
        end
      end
    end
  end
end
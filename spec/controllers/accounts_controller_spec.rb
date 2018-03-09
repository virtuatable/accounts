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

    it_should_behave_like 'a route', 'post', '/'

    describe 'bad request errors' do
      describe 'no username error' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a Bad Request (400) error when the username is not given' do
          expect(last_response.status).to be 400
        end
        it 'returns a correct body when the username is not given' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'missing.username'})
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
          expect(JSON.parse(last_response.body)).to eq({'message' => 'missing.password'})
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
          expect(JSON.parse(last_response.body)).to eq({'message' => 'missing.password_confirmation'})
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
          expect(JSON.parse(last_response.body)).to eq({'message' => 'missing.email'})
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
    describe 'unprocessable entity errors' do
      describe 'already taken username error' do
        before do
          create(:other_account, username: 'Babausse', email: 'another@test.com')
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
          create(:other_account, username: 'Another random username', email: 'test@test.com')
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
    let!(:category) { create(:category) }
    let!(:right) { create(:right, category: category) }
    let!(:group) {
      tmp_group = create(:group, rights: [right], accounts: [account])
      account.groups << tmp_group
      account.save!
      tmp_group
    }
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
        it 'Returns an account with the correct rights' do
          expect(parsed_account['rights']).to eq([{'id' => right.id.to_s, 'slug' => 'test_category.test_right'}])
        end
      end
    end

    it_should_behave_like 'a route', 'get', '/accounts/account_id'

    describe 'not found errors' do
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
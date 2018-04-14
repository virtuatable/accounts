RSpec.describe AccountsController do

  def app
    AccountsController.new
  end

  let!(:account) { create(:account) }
  let!(:gateway) { create(:gateway) }
  let!(:premium_application) { create(:premium_application, creator: account) }
  let!(:application) { create(:application, creator: account) }
  let!(:birthdate) { DateTime.new(1989, 8, 29, 21, 50) }

  describe 'POST /accounts' do
    describe 'Nominal case' do
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
          birthdate: birthdate
        }.to_json
      end
      it 'Returns a Created (201) status' do
        expect(last_response.status).to be 201
      end
      it 'Creates an account' do
        expect(JSON.parse(last_response.body)).to eq({
          'message' => 'created',
          'item' => {
            'id' => Arkaan::Account.where(username: 'Babausse').first.id.to_s,
            'username' => 'Babausse',
            'email' => 'test@test.com',
            'firstname' => 'Vincent',
            'lastname' => 'Courtois',
            'birthdate' => birthdate.utc.iso8601,
            'rights' => []
          }
        })
      end
      describe 'Created account fields' do
        let(:created_account) { Arkaan::Account.where(username: 'Babausse').first }

        it 'Has a username' do
          expect(created_account.username).to eq 'Babausse'
        end
        it 'Has a password digest corresponding to the password' do
          expect(created_account.authenticate('password')).to be_truthy
        end
        it 'Has an email' do
          expect(created_account.email).to eq 'test@test.com'
        end
        it 'Has a first name' do
          expect(created_account.firstname).to eq 'Vincent'
        end
        it 'Has a last name' do
          expect(created_account.lastname).to eq 'Courtois'
        end
        it 'Has a birth date' do
          expect(created_account.birthdate).to eq DateTime.new(1989, 8, 29, 21, 50)
        end
      end
    end

    it_should_behave_like 'a route', 'post', '/'

    describe '400 errors' do
      describe 'Username not given' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a 400 error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'username',
            'error' => 'required'
          })
        end
      end

      describe 'Password not given' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a 400 error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'password',
            'error' => 'required'
          })
        end
      end

      describe 'Password confirmation not given' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a 400 error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'password_confirmation',
            'error' => 'required'
          })
        end
      end

      describe 'Email not given' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'password'}.to_json
        end
        it 'Raises a 400 error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'email',
            'error' => 'required'
          })
        end
      end

      describe 'Username already taken' do
        before do
          create(:other_account, username: 'Babausse', email: 'another@test.com')
          post '/', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a 400 error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'username',
            'error' => 'uniq'
          })
        end
      end

      describe 'Username too short' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', username: 'test', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a 400 error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'username',
            'error' => 'minlength'
          })
        end
      end

      describe 'Email already taken' do
        before do
          create(:other_account, username: 'Another random username', email: 'test@test.com')
          post '/', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a 400 error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'email',
            'error' => 'uniq'
          })
        end
      end

      describe 'Email with a bad format' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test'}.to_json
        end
        it 'Raises a 400 error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'email',
            'error' => 'pattern'
          })
        end
      end

      describe 'Password confirmation not matching' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'another password', email: 'test@test.com'}.to_json
        end
        it 'Raises a 400 error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'password_confirmation',
            'error' => 'confirmation'
          })
        end
      end
    end

    describe '403 errors' do
      describe 'Application not premium' do
        before do
          post '/', {token: 'test_token', app_key: 'other_key', username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a 403 error' do
          expect(last_response.status).to be 403
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 403,
            'field' => 'app_key',
            'error' => 'forbidden'
          })
        end
      end
    end
  end

  describe 'GET /accounts/:id' do
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
        it 'Has a birthdate' do
          expect(DateTime.parse(parsed_account['birthdate'])).to eq(account.birthdate)
        end
        it 'Has rights' do
          expect(parsed_account['rights']).to eq([{'id' => right.id.to_s, 'slug' => 'test_category.test_right'}])
        end
      end
    end

    it_should_behave_like 'a route', 'get', '/accounts/account_id'

    describe '404 errors' do
      describe 'Account ID not found' do
        before do
          get "unexisting_id?token=test_token&app_key=test_key"
        end
        it 'Raises a 404 error' do
          expect(last_response.status).to be 404
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 404,
            'field' => 'account_id',
            'error' => 'unknown',
            'docs' => 'https://github.com/jdr-tools/wiki/wiki/Accounts-API#account-id-not-found'
          })
        end
      end
    end
  end

  describe 'GET /accounts/own' do

    let!(:session) { create(:session, account: account) }

    describe 'Nominal case' do
      before do
        get "/own?session_id=#{session.token}&token=test_token&app_key=test_key"
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
        it 'Has a birthdate' do
          expect(DateTime.parse(parsed_account['birthdate'])).to eq(account.birthdate)
        end
      end
    end

    it_should_behave_like 'a route', 'get', '/accounts/own'

    describe '400 errors' do
      describe 'session ID not given' do
        before do
          get "/own?token=test_token&app_key=test_key"
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
          get "own?session_id=unknown_token&token=test_token&app_key=test_key"
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

  describe 'put /accounts/own' do

    let!(:session) { create(:session, account: account) }

    describe 'Nothing being updated' do
      before do
        put '/own', {session_id: session.token, token: 'test_token', app_key: 'test_key'}
      end
      it 'Returns a OK (200) status' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body' do
        expect(JSON.parse(last_response.body)).to eq({
          'message' => 'updated',
          'item' => {
            'id' => account.id.to_s,
            'username' => account.username,
            'email' => account.email,
            'firstname' => account.firstname,
            'lastname' => account.lastname,
            'birthdate' => account.birthdate.utc.iso8601,
            'rights' => []
          }
        })
      end
      describe 'Campaign parameters' do
        let!(:created_account) { Arkaan::Account.all.first }

        it 'Has a username' do
          expect(created_account.username).to eq 'Autre compte'
        end
        it 'Has a password' do
          expect(created_account.authenticate('long_password')).to be_truthy
        end
        it 'Has an email' do
          expect(created_account.email).to eq 'machin@test.com'
        end
        it 'Has a firstname' do
          expect(created_account.firstname).to eq 'Vincent'
        end
        it 'Has a lastname' do
          expect(created_account.lastname).to eq 'Courtois'
        end
        it 'Has a birthdate' do
          expect(created_account.birthdate).to eq DateTime.new(1989, 8, 29, 21, 50)
        end
      end
    end
    describe 'Username being updated' do
      before do
        put '/own', {session_id: session.token, token: 'test_token', app_key: 'test_key', username: 'Compte de test'}
      end
      it 'Returns a OK (200) status' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body' do
        expect(JSON.parse(last_response.body)).to eq({
          'message' => 'updated',
          'item' => {
            'id' => account.id.to_s,
            'username' => 'Compte de test',
            'email' => account.email,
            'firstname' => account.firstname,
            'lastname' => account.lastname,
            'birthdate' => account.birthdate.utc.iso8601,
            'rights' => []
          }
        })
      end
      it 'Updates the username' do
        expect(Arkaan::Account.first.username).to eq 'Compte de test'
      end
    end
    describe 'Password being updated' do
      before do
        put '/own', {
          session_id: session.token,
          token: 'test_token',
          app_key: 'test_key',
          password: 'new_password',
          password_confirmation: 'new_password'
        }
      end
      it 'Returns a OK (200) status' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body' do
        expect(JSON.parse(last_response.body)).to eq({
          'message' => 'updated',
          'item' => {
            'id' => account.id.to_s,
            'username' => account.username,
            'email' => account.email,
            'firstname' => account.firstname,
            'lastname' => account.lastname,
            'birthdate' => account.birthdate.utc.iso8601,
            'rights' => []
          }
        })
      end
      it 'Updates the password' do
        expect(Arkaan::Account.first.authenticate('new_password')).to be_truthy
      end
    end
    describe 'Email being updated' do
      before do
        put '/own', {session_id: session.token, token: 'test_token', app_key: 'test_key', email: 'test@mail.com'}
      end
      it 'Returns a OK (200) status' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body' do
        expect(JSON.parse(last_response.body)).to eq({
          'message' => 'updated',
          'item' => {
            'id' => account.id.to_s,
            'username' => account.username,
            'email' => 'test@mail.com',
            'firstname' => account.firstname,
            'lastname' => account.lastname,
            'birthdate' => account.birthdate.utc.iso8601,
            'rights' => []
          }
        })
      end
      it 'Updates the email' do
        expect(Arkaan::Account.first.email).to eq 'test@mail.com'
      end
    end
    describe 'first name being updated' do
      before do
        put '/own', {session_id: session.token, token: 'test_token', app_key: 'test_key', firstname: 'Babausse'}
      end
      it 'Returns a OK (200) status' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body' do
        expect(JSON.parse(last_response.body)).to eq({
          'message' => 'updated',
          'item' => {
            'id' => account.id.to_s,
            'username' => account.username,
            'email' => account.email,
            'firstname' => 'Babausse',
            'lastname' => account.lastname,
            'birthdate' => account.birthdate.utc.iso8601,
            'rights' => []
          }
        })
      end
      it 'Updates the first name' do
        expect(Arkaan::Account.first.firstname).to eq 'Babausse'
      end
    end
    describe 'last name being updated' do
      before do
        put '/own', {session_id: session.token, token: 'test_token', app_key: 'test_key', lastname: 'Babausse'}
      end
      it 'Returns a OK (200) status' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body' do
        expect(JSON.parse(last_response.body)).to eq({
          'message' => 'updated',
          'item' => {
            'id' => account.id.to_s,
            'username' => account.username,
            'email' => account.email,
            'firstname' => account.firstname,
            'lastname' => 'Babausse',
            'birthdate' => account.birthdate.utc.iso8601,
            'rights' => []
          }
        })
      end
      it 'Updates the last name' do
        expect(Arkaan::Account.first.lastname).to eq 'Babausse'
      end
    end
    describe 'birth date being updated' do
      before do
        put '/own', {session_id: session.token, token: 'test_token', app_key: 'test_key', birthdate: DateTime.new(2000, 6, 12, 23, 51)}
      end
      it 'Returns a OK (200) status' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body' do
        expect(JSON.parse(last_response.body)).to eq({
          'message' => 'updated',
          'item' => {
            'id' => account.id.to_s,
            'username' => account.username,
            'email' => account.email,
            'firstname' => account.firstname,
            'lastname' => account.lastname,
            'birthdate' => DateTime.new(2000, 6, 12, 23, 51).utc.iso8601,
            'rights' => []
          }
        })
      end
      it 'Updates the birth date' do
        expect(Arkaan::Account.first.birthdate).to eq DateTime.new(2000, 6, 12, 23, 51)
      end
    end

    it_should_behave_like 'a route', 'put', '/accounts/own'

    describe '400 errors' do
      describe 'session ID not given' do
        before do
          put '/own', {token: 'test_token', app_key: 'test_key'}
        end
        it 'Raises a Bad Request (400) status' do
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

      describe 'password confirmation not given' do
        before do
          put '/own', {token: 'test_token', app_key: 'test_key', session_id: session.token, password: 'new_password'}
        end
        it 'Raises a Bad Request (400) status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'password_confirmation',
            'error' => 'required',
          })
        end
      end

      describe 'Username too short' do
        before do
          put '/own', {session_id: session.token, token: 'test_token', app_key: 'test_key', username: 'test'}
        end
        it 'Raises a Bad Request (400) status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'username',
            'error' => 'minlength'
          })
        end
      end

      describe 'Username already used' do
        let!(:second_account) { create(:second_account) }
        before do
          put '/own', {session_id: session.token, token: 'test_token', app_key: 'test_key', username: second_account.username}
        end
        it 'Raises a Bad Request (400) status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'username',
            'error' => 'uniq'
          })
        end
      end

      describe 'Password confirmation not matching' do
        before do
          put '/own', {
            session_id: session.token,
            token: 'test_token',
            app_key: 'test_key',
            password: 'new_password',
            password_confirmation: 'another_new_password'
          }
        end
        it 'Raises a Bad Request (400) status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'password_confirmation',
            'error' => 'confirmation'
          })
        end
      end

      describe 'email already used' do
        let!(:second_account) { create(:second_account) }
        before do
          put '/own', {session_id: session.token, token: 'test_token', app_key: 'test_key', email: second_account.email}
        end
        it 'Raises a Bad Request (400) status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'email',
            'error' => 'uniq'
          })
        end
      end
    end
  end
end
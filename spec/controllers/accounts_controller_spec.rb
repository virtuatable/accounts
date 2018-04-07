RSpec.describe AccountsController do

  def app
    AccountsController.new
  end

  let!(:account) { create(:account) }
  let!(:gateway) { create(:gateway) }
  let!(:premium_application) { create(:premium_application, creator: account) }
  let!(:application) { create(:application, creator: account) }
  let!(:birthdate) { DateTime.new(1989, 8, 29, 21, 50) }

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
          birthdate: birthdate
        }.to_json
      end
      it 'returns a Created (201) code when an account is correctly created' do
        expect(last_response.status).to be 201
      end
      it 'correctly creates an account when all the informations are being given' do
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
      describe 'created account' do
        let(:created_account) { Arkaan::Account.where(username: 'Babausse').first }

        it 'has created an account with the correct username' do
          expect(created_account.username).to eq 'Babausse'
        end
        it 'has created an account with the correct password' do
          expect(created_account.authenticate('password')).to be_truthy
        end
        it 'has created an account with the correct email' do
          expect(created_account.email).to eq 'test@test.com'
        end
        it 'has created an account with the correct first name' do
          expect(created_account.firstname).to eq 'Vincent'
        end
        it 'has created an account with the correct last name' do
          expect(created_account.lastname).to eq 'Courtois'
        end
        it 'has created an account with the correct birth date' do
          expect(created_account.birthdate).to eq DateTime.new(1989, 8, 29, 21, 50)
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
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'username',
            'error' => 'required',
            'docs' => 'https://github.com/jdr-tools/arkaan/wiki/Errors#parameter-not-given'
          })
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
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'password',
            'error' => 'required',
            'docs' => 'https://github.com/jdr-tools/arkaan/wiki/Errors#parameter-not-given'
          })
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
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'password_confirmation',
            'error' => 'required',
            'docs' => 'https://github.com/jdr-tools/arkaan/wiki/Errors#parameter-not-given'
          })
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
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'email',
            'error' => 'required',
            'docs' => 'https://github.com/jdr-tools/arkaan/wiki/Errors#parameter-not-given'
          })
        end
      end
      describe 'already taken username error' do
        before do
          create(:other_account, username: 'Babausse', email: 'another@test.com')
          post '/', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises an Bad Request (400) error when the username is already taken' do
          expect(last_response.status).to be 400
        end
        it 'returns a correct body is the username is already taken' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'username',
            'error' => 'uniq',
            'docs' => 'https://github.com/jdr-tools/accounts/wiki/Creation-of-an-account#username-already-used'
          })
        end
      end
      describe 'too short username error' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', username: 'test', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises an Bad Request (400) error when the username is too short' do
          expect(last_response.status).to be 400
        end
        it 'returns a correct body when the username is too short' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'username',
            'error' => 'minlength',
            'docs' => 'https://github.com/jdr-tools/accounts/wiki/Creation-of-an-account#username-too-short'
          })
        end
      end
      describe 'already taken email error' do
        before do
          create(:other_account, username: 'Another random username', email: 'test@test.com')
          post '/', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises an Bad Request (400) error when the email is already taken' do
          expect(last_response.status).to be 400
        end
        it 'returns a correct body when the email is already taken' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'email',
            'error' => 'uniq',
            'docs' => 'https://github.com/jdr-tools/accounts/wiki/Creation-of-an-account#email-already-used'
          })
        end
      end
      describe 'bad format email error' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test'}.to_json
        end
        it 'Raises an Bad Request (400) error when the email has a wrong format' do
          expect(last_response.status).to be 400
        end
        it 'returns a correct body when the email has a wrong format' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'email',
            'error' => 'pattern',
            'docs' => 'https://github.com/jdr-tools/accounts/wiki/Creation-of-an-account#email-with-a-wrong-format'
          })
        end
      end
      describe 'password confirmation not matching error' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'another password', email: 'test@test.com'}.to_json
        end
        it 'Raises an Bad Request (400) error when the password confirmation does not match the password' do
          expect(last_response.status).to be 400
        end
        it 'returns a correct body when the password confirmation does not match the password' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'password_confirmation',
            'error' => 'confirmation',
            'docs' => 'https://github.com/jdr-tools/accounts/wiki/Creation-of-an-account#password-confirmation-not-matching'
          })
        end
      end
    end
    describe 'unauthorized errors' do
      describe 'not premium application' do
        before do
          post '/', {token: 'test_token', app_key: 'other_key', username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises an Unauthorized (401) error when the application issuing the request is not premium' do
          expect(last_response.status).to be 403
        end
        it 'returns a correct body when the application is not premium' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 403,
            'field' => 'app_key',
            'error' => 'forbidden',
            'docs' => 'https://github.com/jdr-tools/arkaan/wiki/Errors#application-not-premium'
          })
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

        it 'returns an account with the correct id' do
          expect(parsed_account['id']).to eq account.id.to_s
        end
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
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 404,
            'field' => 'account_id',
            'error' => 'unknown',
            'docs' => 'https://github.com/jdr-tools/accounts/wiki/Obtaining-account-informations#not-found-404-errors'
          })
        end
      end
    end
  end

  describe 'get /accounts/own' do

    let!(:session) { create(:session, account: account) }

    describe 'Nominal case' do
      before do
        get "/own?session_id=#{session.token}&token=test_token&app_key=test_key"
      end
      it 'Returns an OK (200) response when the account exists' do
        expect(last_response.status).to be 200
      end
      describe 'Account attributes' do
        let!(:parsed_account) { JSON.parse(last_response.body)['account'] }

        it 'returns an account with the correct id' do
          expect(parsed_account['id']).to eq account.id.to_s
        end
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

    it_should_behave_like 'a route', 'get', '/accounts/own'

    describe 'not found errors' do
      describe 'session not found error' do
        before do
          get "own?session_id=unknown_token&token=test_token&app_key=test_key"
        end
        it 'Returns a Not Found (404) error when the session does not exist' do
          expect(last_response.status).to be 404
        end
        it 'Returns the correct message when an session does not exist' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 404,
            'field' => 'session_id',
            'error' => 'unknown',
            'docs' => 'https://github.com/jdr-tools/arkaan/wiki/Getting-own-profile-informations#session-id-not-found'
          })
        end
      end
    end

    describe 'Bad Request errors' do
      describe 'session ID not given error' do
        before do
          get "/own?token=test_token&app_key=test_key"
        end
        it 'Returns a Bad Request (400) error when the session identifier is not given' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body if the session identifier is not given' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'session_id',
            'error' => 'required',
            'docs' => 'https://github.com/jdr-tools/arkaan/wiki/Errors#parameter-not-given'
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
      it 'Returns a OK (200) response code when the account is updated with nothing' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body when the account is updated with nothing' do
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
      describe 'campaign parameters' do
        let!(:created_account) { Arkaan::Account.all.first }

        it 'has not modified the username of the user' do
          expect(created_account.username).to eq 'Autre compte'
        end
        it 'has not modified the password of the user' do
          expect(created_account.authenticate('long_password')).to be_truthy
        end
        it 'has not modified the email address of the user' do
          expect(created_account.email).to eq 'machin@test.com'
        end
        it 'has not modifier the first name of the user' do
          expect(created_account.firstname).to eq 'Vincent'
        end
        it 'has not modified the last name of the user' do
          expect(created_account.lastname).to eq 'Courtois'
        end
        it 'has not modified the birth date of the user' do
          expect(created_account.birthdate).to eq DateTime.new(1989, 8, 29, 21, 50)
        end
      end
    end
    describe 'username being updated' do
      before do
        put '/own', {session_id: session.token, token: 'test_token', app_key: 'test_key', username: 'Compte de test'}
      end
      it 'Returns a OK (200) response code when the username is correctly updated' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body when the username is updated' do
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
      it 'Correctly updated the username on the user' do
        expect(Arkaan::Account.first.username).to eq 'Compte de test'
      end
    end
    describe 'password being updated' do
      before do
        put '/own', {
          session_id: session.token,
          token: 'test_token',
          app_key: 'test_key',
          password: 'new_password',
          password_confirmation: 'new_password'
        }
      end
      it 'Returns a OK (200) response code when the password is correctly updated' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body when the password is updated' do
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
      it 'Correctly updates the password on the account' do
        expect(Arkaan::Account.first.authenticate('new_password')).to be_truthy
      end
    end
    describe 'email being updated' do
      before do
        put '/own', {session_id: session.token, token: 'test_token', app_key: 'test_key', email: 'test@mail.com'}
      end
      it 'Returns a OK (200) response code when the email is correctly updated' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body when the email is updated' do
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
      it 'Correctly updated the email on the user' do
        expect(Arkaan::Account.first.email).to eq 'test@mail.com'
      end
    end
    describe 'first name being updated' do
      before do
        put '/own', {session_id: session.token, token: 'test_token', app_key: 'test_key', firstname: 'Babausse'}
      end
      it 'Returns a OK (200) response code when the first name is correctly updated' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body when the first name is updated' do
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
      it 'Correctly updated the first name on the user' do
        expect(Arkaan::Account.first.firstname).to eq 'Babausse'
      end
    end
    describe 'last name being updated' do
      before do
        put '/own', {session_id: session.token, token: 'test_token', app_key: 'test_key', lastname: 'Babausse'}
      end
      it 'Returns a OK (200) response code when the last name is correctly updated' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body when the last name is updated' do
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
      it 'Correctly updated the last name on the user' do
        expect(Arkaan::Account.first.lastname).to eq 'Babausse'
      end
    end
    describe 'birth date being updated' do
      before do
        put '/own', {session_id: session.token, token: 'test_token', app_key: 'test_key', birthdate: DateTime.new(2000, 6, 12, 23, 51)}
      end
      it 'Returns a OK (200) response code when the birth date is correctly updated' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body when the birth date is updated' do
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
      it 'Correctly updated the birth date on the user' do
        expect(Arkaan::Account.first.birthdate).to eq DateTime.new(2000, 6, 12, 23, 51)
      end
    end

    it_should_behave_like 'a route', 'put', '/accounts/own'

    describe 'Bad Request errors' do
      describe 'session ID not given error' do
        before do
          put '/own', {token: 'test_token', app_key: 'test_key'}
        end
        it 'Returns a Bad Request (400) error when the session identifier is not given' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body if the session identifier is not given' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'session_id',
            'error' => 'required',
            'docs' => 'https://github.com/jdr-tools/arkaan/wiki/Errors#parameter-not-given'
          })
        end
      end
      describe 'password confirmation not given error' do
        before do
          put '/own', {token: 'test_token', app_key: 'test_key', session_id: session.token, password: 'new_password'}
        end
        it 'Returns a Bad Request (400) error when the password confirmation is not given with the password' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body if the password confirmation is not given with the password' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'password_confirmation',
            'error' => 'required',
            'docs' => 'https://github.com/jdr-tools/arkaan/wiki/Errors#parameter-not-given'
          })
        end
      end
    end

    describe 'Unprocessable Entity errors' do
      describe 'username is too short error' do
        before do
          put '/own', {session_id: session.token, token: 'test_token', app_key: 'test_key', username: 'test'}
        end
        it 'Returns an Bad Request (422) response status if the username is too short' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body if the username is too short' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'username',
            'error' => 'minlength',
            'docs' => 'https://github.com/jdr-tools/accounts/wiki/Creation-of-an-account#username-too-short'
          })
        end
      end
      describe 'username already used when given error' do
        let!(:second_account) { create(:second_account) }
        before do
          put '/own', {session_id: session.token, token: 'test_token', app_key: 'test_key', username: second_account.username}
        end
        it 'Returns an Bad Request (422) response status if the username is already taken' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body if the username is already taken' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'username',
            'error' => 'uniq',
            'docs' => 'https://github.com/jdr-tools/accounts/wiki/Creation-of-an-account#username-already-used'
          })
        end
      end
      describe 'password and confirmation not matching error' do
        before do
          put '/own', {
            session_id: session.token,
            token: 'test_token',
            app_key: 'test_key',
            password: 'new_password',
            password_confirmation: 'another_new_password'
          }
        end
        it 'Returns an Bad Request (400) response status if the confirmation does not match the password' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body if the confirmation does not match the password' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'password_confirmation',
            'error' => 'confirmation',
            'docs' => 'https://github.com/jdr-tools/accounts/wiki/Creation-of-an-account#password-confirmation-not-matching'
          })
        end
      end
      describe 'email already used when given error' do
        let!(:second_account) { create(:second_account) }
        before do
          put '/own', {session_id: session.token, token: 'test_token', app_key: 'test_key', email: second_account.email}
        end
        it 'Returns an Bad Request (422) response status if the email is already taken' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body if the email is already taken' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'email',
            'error' => 'uniq',
            'docs' => 'https://github.com/jdr-tools/accounts/wiki/Creation-of-an-account#email-already-used'
          })
        end
      end
    end
  end
end
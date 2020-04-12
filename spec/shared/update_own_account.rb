RSpec.shared_examples 'PUT /own' do
  describe 'PUT /own' do

    let!(:session) { create(:session, account: account) }

    it_should_behave_like 'a route', 'put', '/own', {authenticated: true}

    describe 'Nothing being updated' do
      before do
        put '/own', {
          session_id: session.token,
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
          lastname: account.lastname,
          rights: [],
          language: 'fr_FR',
          gender: 'neutral'
        )
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
        it 'has a language' do
          expect(created_account.language).to eq :fr_FR
        end
        it 'has a gender' do
          expect(created_account.gender).to eq :neutral
        end
      end
    end
    describe 'Username being updated' do
      before do
        put '/own', {
          session_id: session.token,
          app_key: 'test_key',
          username: 'Compte de test'
        }
      end
      it 'Returns a OK (200) status' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body' do
        expect(last_response.body).to include_json(
          id: account.id.to_s,
          username: 'Compte de test',
          email: account.email,
          firstname: account.firstname,
          lastname: account.lastname,
          rights: [],
          language: 'fr_FR',
          gender: 'neutral'
        )
      end
      it 'Updates the username' do
        expect(Arkaan::Account.first.username).to eq 'Compte de test'
      end
    end
    describe 'Password being updated' do
      before do
        put '/own', {
          session_id: session.token,
          app_key: 'test_key',
          password: 'new_password',
          password_confirmation: 'new_password'
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
          lastname: account.lastname,
          rights: [],
          language: 'fr_FR',
          gender: 'neutral'
        )
      end
      it 'Updates the password' do
        expect(Arkaan::Account.first.authenticate('new_password')).to be_truthy
      end
    end
    describe 'Email being updated' do
      before do
        put '/own', {
          session_id: session.token,
          app_key: 'test_key',
          email: 'test@mail.com'
        }
      end
      it 'Returns a OK (200) status' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body' do
        expect(last_response.body).to include_json(
          id: account.id.to_s,
          username: account.username,
          email: 'test@mail.com',
          firstname: account.firstname,
          lastname: account.lastname,
          rights: [],
          language: 'fr_FR',
          gender: 'neutral'
        )
      end
      it 'Updates the email' do
        expect(Arkaan::Account.first.email).to eq 'test@mail.com'
      end
    end
    describe 'first name being updated' do
      before do
        put '/own', {
          session_id: session.token,
          app_key: 'test_key',
          firstname: 'Babausse'
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
          firstname: 'Babausse',
          lastname: account.lastname,
          rights: [],
          language: 'fr_FR',
          gender: 'neutral'
        )
      end
      it 'Updates the first name' do
        expect(Arkaan::Account.first.firstname).to eq 'Babausse'
      end
    end
    describe 'last name being updated' do
      before do
        put '/own', {
          session_id: session.token,
          app_key: 'test_key',
          lastname: 'Babausse'
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
          lastname: 'Babausse',
          rights: [],
          language: 'fr_FR',
          gender: 'neutral'
        )
      end
      it 'Updates the last name' do
        expect(Arkaan::Account.first.lastname).to eq 'Babausse'
      end
    end
    describe 'language being updated' do
      before do
        put '/own', {
          session_id: session.token,
          app_key: 'test_key',
          language: 'en_GB'
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
          lastname: account.lastname,
          rights: [],
          language: 'en_GB',
          gender: 'neutral'
        )
      end
      it 'Updates the last name' do
        expect(Arkaan::Account.first.language).to eq :en_GB
      end
    end
    describe 'gender being updated' do
      before do
        put '/own', {
          session_id: session.token,
          app_key: 'test_key',
          gender: 'male'
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
          lastname: account.lastname,
          rights: [],
          language: 'fr_FR',
          gender: 'male'
        )
      end
      it 'Updates the last name' do
        expect(Arkaan::Account.first.gender).to eq :male
      end
    end

    describe '400 errors' do
      describe 'session ID not given' do
        before do
          put '/own', {
            app_key: 'test_key'
          }
        end
        it 'Raises a Bad Request (400) status' do
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

      describe 'password confirmation not given' do
        before do
          put '/own', {
            app_key: 'test_key',
            session_id: session.token,
            password: 'new_password'
          }
        end
        it 'Raises a Bad Request (400) status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json(
            status: 400,
            field: 'password_confirmation',
            error: 'required'
          )
        end
      end

      describe 'Username too short' do
        before do
          put '/own', {
            session_id: session.token,
            app_key: 'test_key',
            username: 'test'
          }
        end
        it 'Raises a Bad Request (400) status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json(
            status: 400,
            field: 'username',
            error: 'minlength'
          )
        end
      end

      describe 'Username already used' do
        let!(:second_account) { create(:second_account) }
        before do
          put '/own', {
            session_id: session.token,
            app_key: 'test_key',
            username: second_account.username
          }
        end
        it 'Raises a Bad Request (400) status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json(
            status: 400,
            field: 'username',
            error: 'uniq'
          )
        end
      end

      describe 'Password confirmation not matching' do
        before do
          put '/own', {
            session_id: session.token,
            app_key: 'test_key',
            password: 'new_password',
            password_confirmation: 'another_new_password'
          }
        end
        it 'Raises a Bad Request (400) status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json(
            status: 400,
            field: 'password_confirmation',
            error: 'confirmation'
          )
        end
      end

      describe 'email already used' do
        let!(:second_account) { create(:second_account) }
        before do
          put '/own', {
            session_id: session.token,
            app_key: 'test_key',
            email: second_account.email
          }
        end
        it 'Raises a Bad Request (400) status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json(
            status: 400,
            field: 'email',
            error: 'uniq'
          )
        end
      end
    end
  end
end
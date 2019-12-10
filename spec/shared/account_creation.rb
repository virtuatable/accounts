RSpec.shared_examples 'POST /' do
  describe 'POST /accounts' do
    describe 'Nominal case' do
      before do
        post '/accounts', {
          token: 'test_token',
          app_key: 'test_key',
          username: 'Babausse',
          password: 'password',
          password_confirmation: 'password',
          email: 'test@test.com',
          firstname: 'Vincent',
          lastname: 'Courtois',
          language: 'en_GB',
          gender: 'male'
        }.to_json
      end
      it 'Returns a Created (201) status' do
        expect(last_response.status).to be 201
      end
      it 'Creates an account' do
        expect(last_response.body).to include_json({
          message: 'created',
          item: {
            id: Arkaan::Account.where(username: 'Babausse').first.id.to_s,
            username: 'Babausse',
            email: 'test@test.com',
            firstname: 'Vincent',
            lastname: 'Courtois',
            language: 'en_GB',
            gender: 'male',
            rights: []
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
        it 'Has a preferred language' do
          expect(created_account.language).to eq :en_GB
        end
        it 'Has a preferred gender' do
          expect(created_account.gender).to eq :male
        end
      end
    end

    describe 'Alternative cases' do
      describe 'There is a default group in the DB' do
        let!(:category) { create(:category) }
        let!(:right) { create(:right, category: category) }
        let!(:default_group) { create(:default_group, rights: [right]) }

        before do
          post '/accounts', {
            token: 'test_token',
            app_key: 'test_key',
            username: 'Babausse',
            password: 'password',
            password_confirmation: 'password',
            email: 'test@test.com',
            firstname: 'Vincent',
            lastname: 'Courtois',
            language: 'en_GB',
            gender: 'male'
          }.to_json
        end
        it 'Returns a 201 (Created) status' do
          expect(last_response.status).to be 201
        end
        it 'returns the correct body' do
          expect(last_response.body).to include_json({
            message: 'created',
            item: {
              id: Arkaan::Account.where(username: 'Babausse').first.id.to_s,
              username: 'Babausse',
              email: 'test@test.com',
              firstname: 'Vincent',
              lastname: 'Courtois',
              language: 'en_GB',
              gender: 'male',
              rights: [{id: right.id.to_s, slug: 'test_category.test_right'}]
            }
          })
        end
        it 'Has given groups to the created account' do
          expect(Arkaan::Account.where(username: 'Babausse').first.groups.first.slug).to eq 'test_group'
        end
      end
      
      describe 'when the language or the gender are not given' do
        before do
          post '/accounts', {
            token: 'test_token',
            app_key: 'test_key',
            username: 'Babausse',
            password: 'password',
            password_confirmation: 'password',
            email: 'test@test.com',
            firstname: 'Vincent',
            lastname: 'Courtois',
          }.to_json
        end
        it 'Returns a Created (201) status' do
          expect(last_response.status).to be 201
        end
        it 'Creates an account' do
          expect(last_response.body).to include_json({
            message: 'created',
            item: {
              id: Arkaan::Account.where(username: 'Babausse').first.id.to_s,
              username: 'Babausse',
              email: 'test@test.com',
              firstname: 'Vincent',
              lastname: 'Courtois',
              language: 'fr_FR',
              gender: 'neutral',
              rights: []
            }
          })
        end
        describe 'account attributes' do
          let(:created_account) { Arkaan::Account.where(username: 'Babausse').first }

          it 'Has a default language' do
            expect(created_account.language).to eq :fr_FR
          end
          it 'Has a default gender' do
            expect(created_account.gender).to eq :neutral
          end
        end
      end
      
      describe 'when the language or the gender are not in the available list' do
        before do
          post '/accounts', {
            token: 'test_token',
            app_key: 'test_key',
            username: 'Babausse',
            password: 'password',
            password_confirmation: 'password',
            email: 'test@test.com',
            firstname: 'Vincent',
            lastname: 'Courtois',
            language: 'martian',
            gender: 'shark'
          }.to_json
        end
        it 'Returns a Created (201) status' do
          expect(last_response.status).to be 201
        end
        it 'Creates an account' do
          expect(last_response.body).to include_json({
            message: 'created',
            item: {
              id: Arkaan::Account.where(username: 'Babausse').first.id.to_s,
              username: 'Babausse',
              email: 'test@test.com',
              firstname: 'Vincent',
              lastname: 'Courtois',
              language: 'fr_FR',
              gender: 'neutral',
              rights: []
            }
          })
        end
        describe 'account attributes' do
          let(:created_account) { Arkaan::Account.where(username: 'Babausse').first }

          it 'Has a default language' do
            expect(created_account.language).to eq :fr_FR
          end
          it 'Has a default gender' do
            expect(created_account.gender).to eq :neutral
          end
        end
      end
    end

    it_should_behave_like 'a route', 'post', '/accounts', {authenticated: false, premium: true}

    describe '400 errors' do
      describe 'Username not given' do
        before do
          post '/accounts', {token: 'test_token', app_key: 'test_key', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a 400 error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            status: 400,
            field: 'username',
            error: 'required'
          })
        end
      end

      describe 'Password not given' do
        before do
          post '/accounts', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a 400 error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            status: 400,
            field: 'password',
            error: 'required'
          })
        end
      end

      describe 'Password confirmation not given' do
        before do
          post '/accounts', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a 400 error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            status: 400,
            field: 'password_confirmation',
            error: 'required'
          })
        end
      end

      describe 'Email not given' do
        before do
          post '/accounts', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'password'}.to_json
        end
        it 'Raises a 400 error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            status: 400,
            field: 'email',
            error: 'required'
          })
        end
      end

      describe 'Username already taken' do
        before do
          create(:other_account, username: 'Babausse', email: 'another@test.com')
          post '/accounts', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a 400 error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            status: 400,
            field: 'username',
            error: 'uniq'
          })
        end
      end

      describe 'Username too short' do
        before do
          post '/accounts', {token: 'test_token', app_key: 'test_key', username: 'test', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a 400 error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            status: 400,
            field: 'username',
            error: 'minlength'
          })
        end
      end

      describe 'Email already taken' do
        before do
          create(:other_account, username: 'Another random username', email: 'test@test.com')
          post '/accounts', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a 400 error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            status: 400,
            field: 'email',
            error: 'uniq'
          })
        end
      end

      describe 'Email with a bad format' do
        before do
          post '/accounts', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test'}.to_json
        end
        it 'Raises a 400 error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            status: 400,
            field: 'email',
            error: 'pattern'
          })
        end
      end

      describe 'Password confirmation not matching' do
        before do
          post '/accounts', {token: 'test_token', app_key: 'test_key', username: 'Babausse', password: 'password', password_confirmation: 'another password', email: 'test@test.com'}.to_json
        end
        it 'Raises a 400 error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            status: 400,
            field: 'password_confirmation',
            error: 'confirmation'
          })
        end
      end
    end

    describe '403 errors' do
      describe 'Application not premium' do
        before do
          post '/accounts', {token: 'test_token', app_key: 'other_key', username: 'Babausse', password: 'password', password_confirmation: 'password', email: 'test@test.com'}.to_json
        end
        it 'Raises a 403 error' do
          expect(last_response.status).to be 403
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            status: 403,
            field: 'app_key',
            error: 'forbidden'
          })
        end
      end
    end
  end
end
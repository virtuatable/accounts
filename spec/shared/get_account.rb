RSpec.shared_examples 'GET /:id' do
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
        get "/accounts/#{account.id.to_s}?token=test_token&app_key=test_key"
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
        it 'Has a language' do
          expect(parsed_account['language']).to eq(account.language.to_s)
        end
        it 'Has a preferred gender' do
          expect(parsed_account['gender']).to eq(account.gender.to_s)
        end
        it 'Returns an account with the correct rights' do
          expect(parsed_account['rights']).to eq([{'id' => right.id.to_s, 'slug' => 'test_category.test_right'}])
        end
      end
    end

    it_should_behave_like 'a route', 'get', '/accounts/account_id'

    describe '404 errors' do
      describe 'Account ID not found' do
        before do
          get "/accounts/unexisting_id?token=test_token&app_key=test_key"
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
end
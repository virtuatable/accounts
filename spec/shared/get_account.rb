RSpec.shared_examples 'GET /:id' do
  describe 'GET /:id' do
    let!(:category) { create(:category) }
    let!(:right) { create(:right, category: category) }
    let!(:group) {
      tmp_group = create(:group, rights: [right], accounts: [account])
      account.groups << tmp_group
      account.save!
      tmp_group
    }
    let!(:session) { create(:session, account: account) }

    it_should_behave_like 'a route', 'get', '/account_id', {authenticated: true}

    describe 'Nominal case' do
      before do
        get "/#{account.id.to_s}", {
          app_key: application.key,
          session_id: session.token
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
          language: account.language.to_s,
          gender: account.gender.to_s,
          rights: [{slug: 'test_category.test_right'}]
        )
      end
    end

    describe '404 errors' do
      describe 'Account ID not found' do
        before do
          get '/unexisting_id', {
            app_key: application.key,
            session_id: session.token
          }
        end
        it 'Raises a 404 error' do
          expect(last_response.status).to be 404
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json(
            status: 404,
            field: 'account_id',
            error: 'unknown'
          )
        end
      end
    end
  end
end
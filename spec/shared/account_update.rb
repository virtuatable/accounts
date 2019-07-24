RSpec.shared_examples 'PUT /:id' do
  describe 'PUT /accounts/:id' do
    let!(:session) { create(:session, account: account) }
    let!(:group) { create(:group) }
    let!(:other_account) { create(:account, id: 'other_account_id', username: 'Other user', email: 'otheruser@mail.com') }

    describe 'Nominal case' do
      before do
        put "/accounts/#{other_account.id}", {session_id: session.token, token: 'test_token', app_key: 'test_key', groups: [group.id.to_s]}
      end
      it 'Returns a OK (200) status code' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body' do
        expect(last_response.body).to include_json(
          message: 'updated',
          item: {
            id: other_account.id.to_s
          }
        )
      end
    end

    describe 'Errors' do
      describe 'Not found errors' do
        describe 'When the account is not found' do
          before do
            put "/accounts/fake_id", {session_id: session.token, token: 'test_token', app_key: 'test_key', groups: [group.id.to_s]}
          end
          it 'Returns a Not Found (404) error code' do
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
        describe 'When any of the groups is not found' do
          before do
            put "/accounts/#{other_account.id}", {session_id: session.token, token: 'test_token', app_key: 'test_key', groups: ['fake_id']}
          end
          it 'Returns a Not Found (404) error code' do
            expect(last_response.status).to be 404
          end
          it 'Returns the correct body' do
            expect(last_response.body).to include_json(
              status: 404,
              field: 'group_id',
              error: 'unknown'
            )
          end
        end
      end
    end

    it_should_behave_like 'a route', 'put', '/:id'
  end
end
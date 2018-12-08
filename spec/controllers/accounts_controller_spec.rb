RSpec.describe AccountsController do

  def app
    AccountsController.new
  end

  let!(:account) { create(:account) }
  let!(:gateway) { create(:gateway) }
  let!(:premium_application) { create(:premium_application, creator: account) }
  let!(:application) { create(:application, creator: account) }

  include_examples 'POST /'

  include_examples 'GET /:id'

  include_examples 'GET /own'

  include_examples 'PUT /own'

  describe 'PATCH /accounts/own/phones' do
    let!(:session) { create(:session, account: account) }

    describe 'Nominal case' do
      before do
        patch '/accounts/own/phones', {token: 'test_token', app_key: 'test_key', session_id: session.token, privacy: 'players', number: '06.07.08.09.10'}
      end
      it 'Returns a Created (201) status' do
        expect(last_response.status).to be 201
      end
      it 'Returns the correct body' do
        expect(last_response.body).to include_json({
          message: 'created',
          item: {
            number: '06.07.08.09.10',
            privacy: 'players'
          }
        })
      end
    end

    it_should_behave_like 'a route', 'patch', '/accounts/own/phones'

    describe '400 errors' do
      describe 'session ID not given' do
        before do
          patch '/accounts/own/phones', {token: 'test_token', app_key: 'test_key', privacy: 'players', number: '06.07.08.09.10'}
        end
        it 'Returns a 400 status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            status: 400,
            field: 'session_id',
            error: 'required'
          })
        end
      end
      describe 'number not given' do
        before do
          patch '/accounts/own/phones', {token: 'test_token', app_key: 'test_key', session_id: session.token, privacy: 'players'}
        end
        it 'Returns a 400 status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            status: 400,
            field: 'number',
            error: 'required'
          })
        end
      end
      describe 'privacy not given' do
        before do
          patch '/accounts/own/phones', {token: 'test_token', app_key: 'test_key', session_id: session.token, number: '06.07.08.09.10'}
        end
        it 'Returns a 400 status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            status: 400,
            field: 'privacy',
            error: 'required'
          })
        end
      end
      describe 'wrong privacy value' do
        before do
          patch '/accounts/own/phones', {token: 'test_token', app_key: 'test_key', session_id: session.token, privacy: 'anything', number: '06.07.08.09.10'}
        end
        it 'Returns a 400 status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            status: 400,
            field: 'privacy',
            error: 'wrong_value'
          })
        end
      end
    end

    describe '404 errors' do
      describe 'session not found' do
        before do
          patch '/accounts/own/phones', {token: 'test_token', app_key: 'test_key', session_id: 'unknown_token', privacy: 'players', number: '06.07.08.09.10'}
        end
        it 'Returns a 404 status' do
          expect(last_response.status).to be 404
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            status: 404,
            field: 'session_id',
            error: 'unknown'
          })
        end
      end
    end
  end

  describe 'DELETE /accounts/own/phones/:phone_id' do
    let!(:session) { create(:session, account: account) }
    let!(:phone) { create(:phone, account: account) }

    describe 'Nominal case' do
      before do
        delete '/accounts/own/phones/phone_id', {token: 'test_token', app_key: 'test_key', session_id: session.token}
      end
      it 'Returns a OK (200) status' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body' do
        expect(last_response.body).to include_json({message: 'deleted'})
      end
      it 'Has deleted the phone' do

      end
    end

    it_should_behave_like 'a route', 'delete', '/accounts/own/phone'

    describe '400 errors' do
      describe 'session ID not given' do
        before do
          delete '/accounts/own/phones/phone_id', {token: 'test_token', app_key: 'test_key'}
        end
        it 'Returns a 400 status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            status: 400,
            field: 'session_id',
            error: 'required'
          })
        end
      end
    end

    describe '404 errors' do
      describe 'session not found' do
        before do
          delete '/accounts/own/phones/phone_id', {token: 'test_token', app_key: 'test_key', session_id: 'unknown_token'}
        end
        it 'Returns a 404 status' do
          expect(last_response.status).to be 404
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            status: 404,
            field: 'session_id',
            error: 'unknown'
          })
        end
      end
      describe 'phone not found' do
        before do
          delete '/accounts/own/phones/unknown_phone_id', {token: 'test_token', app_key: 'test_key', session_id: session.token}
        end
        it 'Returns a 404 status' do
          expect(last_response.status).to be 404
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            status: 404,
            field: 'phone_id',
            error: 'unknown'
          })
        end
      end
    end
  end
end
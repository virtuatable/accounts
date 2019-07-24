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

  include_examples 'PUT /:id'
end
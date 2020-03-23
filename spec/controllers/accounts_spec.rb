RSpec.describe Controllers::Accounts do

  def app
    Controllers::Accounts.new
  end

  let!(:account) { create(:account) }
  let!(:premium_application) { create(:premium_application, creator: account) }
  let!(:application) { create(:application, creator: account) }

  # bundle exec rspec spec/controllers/accounts_spec.rb[1:1]
  include_examples 'POST /'
  # bundle exec rspec spec/controllers/accounts_spec.rb[1:2]
  include_examples 'GET /:id'
  # bundle exec rspec spec/controllers/accounts_spec.rb[1:3]
  include_examples 'GET /own'
  # bundle exec rspec spec/controllers/accounts_spec.rb[1:4]
  include_examples 'PUT /own'
  # bundle exec rspec spec/controllers/accounts_spec.rb[1:5]
  include_examples 'PUT /:id'
end
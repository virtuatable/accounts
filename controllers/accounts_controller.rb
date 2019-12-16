# frozen_string_literal: true

module Controllers
  # Main controller of the application, creating and destroying sessions.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Accounts < Virtuatable::Controllers::Base
    api_route 'post', '/', options: { authenticated: false, premium: true } do
      check_presence('username', 'password', 'password_confirmation', 'email')
      account = service.create(account_parameters)
      api_created account
    end

    api_route 'get', '/own' do
      api_item account
    end

    api_route 'get', '/:id' do
      api_item account_from_url
    end

    api_route 'put', '/own' do
      check_presence('password_confirmation') if params.key?('password')
      account.update_attributes(account_parameters)
      account.save!
      api_item account
    end

    api_route 'put', '/:id' do
      account = account_from_url
      if params.key? 'groups'
        api_not_found 'group_id.unknown' if unknown_groups?
        account.group_ids = params['groups']
        account.save!
        api_item account
      end
    end

    def unknown_groups?
      params['groups'].any? do |group_id|
        Arkaan::Permissions::Group.find(group_id).nil?
      end
    end

    # Selects the parameters suited to create an account.
    # @return [Hash<String, Object>] the hash composed of the selected keys.
    def account_parameters
      select_params(
        'email',
        'firstname',
        'gender',
        'language',
        'lastname',
        'password',
        'password_confirmation',
        'username'
      )
    end

    def account_from_url
      account = Arkaan::Account.find(params[:id])
      api_not_found 'account_id.unknown' if account.nil?
      account
    end

    def select_params(*fields)
      params.select { |key| fields.include?(key) }
    end

    def service
      Services::Accounts.instance
    end
  end
end

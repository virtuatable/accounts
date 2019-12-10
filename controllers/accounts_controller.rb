# frozen_string_literal: true

module Controllers
  # Main controller of the application, creating and destroying sessions.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Accounts < Virtuatable::Controllers::Base

    # @see https://github.com/jdr-tools/accounts/wiki/Creation-of-an-account
    api_route('post', '/', options: { authenticated: false, premium: true }) do
      check_presence('username', 'password', 'password_confirmation', 'email')
      account = Services::Accounts.instance.create(account_parameters)
      account.save!
      api_created({
        message: 'created',
        item: account.enhance!.to_h
      })
    end

    # declare_route('get', '/own') do
    #   session = check_session('own')
    #   halt 200, { account: Decorators::Account.new(session.account).to_h }.to_json
    # end

    # # @see https://github.com/jdr-tools/accounts/wiki/Obtaining-account-informations
    # declare_route('get', '/:account_id') do
    #   account = Arkaan::Account.where(id: params[:account_id]).first
    #   if account.nil?
    #     custom_error 404, 'informations.account_id.unknown'
    #   else
    #     halt 200, { account: Decorators::Account.new(account).to_h }.to_json
    #   end
    # end

    # declare_route('put', '/own') do
    #   if params.key?('password')
    #     check_presence('password_confirmation', route: 'update_own')
    #   end
    #   session = check_session('update_own')
    #   account = session.account
    #   if account.update_attributes(account_parameters)
    #     item = Decorators::Account.new(account).to_h
    #     halt 200, { message: 'updated', item: item }.to_json
    #   else
    #     model_error(account, 'update_own')
    #   end
    # end

    # declare_premium_route('put', '/:id') do
    #   check_session('update')
    #   account = Arkaan::Account.where(id: params['id']).first
    #   custom_error 404, 'update.account_id.unknown' if account.nil?
    #   if params.key? 'groups'
    #     unknown_groups_exist = params['groups'].any? do |group_id|
    #       Arkaan::Permissions::Group.where(id: group_id).first.nil?
    #     end
    #     custom_error 404, 'update.group_id.unknown' if unknown_groups_exist
    #     account.group_ids = params['groups']
    #     if account.save
    #       item = Decorators::Account.new(account).to_h
    #       halt 200, { message: 'updated', item: item }.to_json
    #     else
    #       model_error(account, 'update')
    #     end
    #   end
    # end

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

    def select_params(*fields)
      params.select { |key| fields.include?(key) }
    end
  end
end
# frozen_string_literal: true

module Controllers
  # Main controller of the application, creating and destroying sessions.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Accounts < Virtuatable::Controllers::Base

    # @see https://github.com/jdr-tools/accounts/wiki/Creation-of-an-account
    api_route 'post', '/', options: { authenticated: false, premium: true } do
      check_presence('username', 'password', 'password_confirmation', 'email')
      account = Services::Accounts.instance.create(account_parameters)
      account.save!
      api_created({
        message: 'created',
        item: account.enhance!.to_h
      })
    end

    api_route 'put', '/:id' do
      updated = get_account
      if params.key? 'groups'
        unknown_groups_exist = params['groups'].any? do |group_id|
          Arkaan::Permissions::Group.where(id: group_id).first.nil?
        end
        api_not_found 'group_id.unknown' if unknown_groups_exist
        updated.group_ids = params['groups']
        updated.save!
        api_item({
          message: 'updated',
          item: updated.enhance!.to_h
        })
      end
    end

    api_route 'get', '/own' do
      halt 200, { account: account!.enhance!.to_h }.to_json
    end

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

    def get_account
      account = Arkaan::Account.where(id: params['id']).first
      api_not_found 'account_id.unknown' if account.nil?
      account
    end

    def select_params(*fields)
      params.select { |key| fields.include?(key) }
    end
  end
end
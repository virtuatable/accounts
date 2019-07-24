# frozen_string_literal: true

# Main controller of the application, creating and destroying sessions.
# @author Vincent Courtois <courtois.vincent@outlook.com>
class AccountsController < Arkaan::Utils::Controllers::Checked

  load_errors_from __FILE__

  # @see https://github.com/jdr-tools/accounts/wiki/Creation-of-an-account
  declare_premium_route('post', '/', options: {authenticated: false}) do
    check_presence('username', 'password', 'password_confirmation', 'email', route: 'creation')
    account = Services::Accounts.instance.create(account_parameters)
    if account.save
      halt 201, {message: 'created', item: Decorators::Account.new(account).to_h}.to_json
    else
      model_error(account, 'creation')
    end
  end

  declare_route('get', '/own') do
    session = check_session('own')
    halt 200,  {account: Decorators::Account.new(session.account).to_h}.to_json
  end

  # @see https://github.com/jdr-tools/accounts/wiki/Obtaining-account-informations
  declare_route('get', '/:account_id') do
    account = Arkaan::Account.where(id: params[:account_id]).first
    if account.nil?
      custom_error 404, 'informations.account_id.unknown'
    else
      halt 200,  {account: Decorators::Account.new(account).to_h}.to_json
    end
  end

  declare_route('put', '/own') do
    check_presence('password_confirmation', route: 'update_own') if params.has_key?('password')
    session = check_session('update_own')
    account = session.account
    if account.update_attributes(account_parameters)
      halt 200, {message: 'updated', item: Decorators::Account.new(account).to_h}.to_json
    else
      model_error(account, 'update_own')
    end
  end

  declare_premium_route('put', '/:id') do
    session = check_session('update')
    account = Arkaan::Account.where(id: params['id']).first
    custom_error 404, 'update.account_id.unknown' if account.nil?
    if params.has_key? 'groups'
      custom_error 404, 'update.group_id.unknown' if params['groups'].any? do |group_id|
        Arkaan::Permissions::Group.where(id: group_id).first.nil?
      end
      account.group_ids = params['groups']
      if account.save
        halt 200, {message: 'updated', item: Decorators::Account.new(account).to_h}.to_json
      else
        model_error(account, 'update')
      end
    end
  end

  # Selects the parameters suited to create an account.
  # @return [Hash<String, Object>] the hash composed of the selected keys.
  def account_parameters
    return select_params('username', 'password', 'password_confirmation', 'firstname', 'lastname', 'email', 'gender', 'language')
  end

  def select_params(*fields)
    return params.select { |key, value| fields.include?(key) }
  end
end

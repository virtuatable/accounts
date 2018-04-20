# frozen_string_literal: true

# Main controller of the application, creating and destroying sessions.
# @author Vincent Courtois <courtois.vincent@outlook.com>
class AccountsController < Arkaan::Utils::Controller

  load_errors_from __FILE__

  # @see https://github.com/jdr-tools/accounts/wiki/Creation-of-an-account
  declare_premium_route('post', '/') do
    check_presence('username', 'password', 'password_confirmation', 'email', route: 'creation')
    account = Arkaan::Account.new(account_parameters)
    if account.save
      halt 201, {message: 'created', item: Decorators::Account.new(account).to_h}.to_json
    else
      model_error(account, 'creation')
    end
  end

  declare_route('get', '/own') do
    check_presence('session_id', route: 'own')
    session = Arkaan::Authentication::Session.where(token: params['session_id']).first
    if session.nil?
      custom_error 404, 'own.session_id.unknown'
    else
      halt 200,  {account: Decorators::Account.new(session.account).to_h}.to_json
    end
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
    check_presence('session_id', route: 'update_own')
    check_presence('password_confirmation', route: 'update_own') if params.has_key?('password')
    session = Arkaan::Authentication::Session.where(token: params['session_id']).first
    if session.nil?
      custom_error(404, 'update_own.session_id.unknown')
    else
      account = session.account
      if account.update_attributes(account_parameters)
        halt 200, {message: 'updated', item: Decorators::Account.new(account).to_h}.to_json
      else
        model_error(account, 'update_own')
      end
    end
  end

  # Selects the parameters suited to create an account.
  # @return [Hash<String, Object>] the hash composed of the selected keys.
  def account_parameters
    params.select do |key, value|
      ['username', 'password', 'password_confirmation', 'firstname', 'lastname', 'email'].include?(key)
    end
  end
end

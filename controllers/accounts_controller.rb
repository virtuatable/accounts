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

  declare_route('patch', '/own/phones') do
    session = check_session('add_phone')
    check_presence('number', 'privacy', route: 'add_phone')
    custom_error(400, 'add_phone.privacy.wrong_value') if !['players', 'private', 'public'].include?(params['privacy'])
    phone = Arkaan::Phone.new(phone_parameters.merge(account: session.account))
    if phone.save
      halt 201, {message: 'created', item: Decorators::Phone.new(phone).to_h}.to_json
    else
      model_error(phone, 'add_phone')
    end
  end

  declare_route('delete', '/own/phones/:phone_id') do
    session = check_session('phone_deletion')
    phone = session.account.phones.where(id: params['phone_id']).first
    if phone.nil?
      custom_error(404, 'phone_deletion.phone_id.unknown')
    else
      phone.delete
      halt 200, {message: 'deleted'}.to_json
    end
  end

  # Checks if the session ID is given in the parameters and if the session exists.
  # @param action [String] the action used to get the errors from the errors file.
  # @return [Arkaan::Authentication::Session] the session when it exists.
  def check_session(action)
    check_presence('session_id', route: action)
    session = Arkaan::Authentication::Session.where(token: params['session_id']).first
    if session.nil?
      custom_error(404, "#{action}.session_id.unknown")
    end
    return session
  end

  # Selects the parameters suited to create an account.
  # @return [Hash<String, Object>] the hash composed of the selected keys.
  def account_parameters
    return select_params('username', 'password', 'password_confirmation', 'firstname', 'lastname', 'email')
  end

  def phone_parameters
    return select_params('number', 'privacy')
  end

  def select_params(*fields)
    return params.select { |key, value| fields.include?(key) }
  end
end

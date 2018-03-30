# frozen_string_literal: true

# Main controller of the application, creating and destroying sessions.
# @author Vincent Courtois <courtois.vincent@outlook.com>
class AccountsController < Arkaan::Utils::Controller

  # @see https://github.com/jdr-tools/accounts/wiki/Creation-of-an-account
  declare_premium_route('post', '/') do
    check_presence('username', 'password', 'password_confirmation', 'email')
    account = Arkaan::Account.new(account_parameters)
    if account.save
      halt 201, {message: 'created', account: Decorators::Account.new(account).to_h}.to_json
    else
      halt 422, {errors: account.errors.messages.values.flatten}.to_json
    end
  end

  # @see https://github.com/jdr-tools/accounts/wiki/Obtaining-account-informations
  declare_route('get', '/:id') do
    account = Arkaan::Account.where(id: params[:id]).first
    if account.nil?
      halt 404, {message: 'account_not_found'}.to_json
    else
      halt 200,  {account: Decorators::Account.new(account).to_h}.to_json
    end
  end

  declare_route('put', '/own') do
    check_presence('session_id')
    session = Arkaan::Authentication::Session.where(token: params['session_id']).first
    if session.nil?
      halt 404, {message: 'session_not_found'}.to_json
    else
      account = session.account
      if account.update_attributes(account_parameters)
        halt 200, {message: 'updated'}.to_json
      else
        halt 422, {errors: account.errors.messages.values.flatten}.to_json
      end
    end
  end

  # Selects the parameters suited to create an account.
  # @return [Hash<String, Object>] the hash composed of the selected keys.
  def account_parameters
    params.select do |key, value|
      ['username', 'password', 'password_confirmation', 'firstname', 'lastname', 'birthdate', 'email'].include?(key)
    end
  end
end

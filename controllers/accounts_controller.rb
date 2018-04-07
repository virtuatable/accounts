# frozen_string_literal: true

# Main controller of the application, creating and destroying sessions.
# @author Vincent Courtois <courtois.vincent@outlook.com>
class AccountsController < Arkaan::Utils::Controller

  @@docs = {
    'email.pattern' => 'https://github.com/jdr-tools/accounts/wiki/Creation-of-an-account#email-with-a-wrong-format',
    'email.uniq' => 'https://github.com/jdr-tools/accounts/wiki/Creation-of-an-account#email-already-used',
    'password_confirmation.confirmation' => 'https://github.com/jdr-tools/accounts/wiki/Creation-of-an-account#password-confirmation-not-matching',
    'username.uniq' => 'https://github.com/jdr-tools/accounts/wiki/Creation-of-an-account#username-already-used',
    'username.minlength' => 'https://github.com/jdr-tools/accounts/wiki/Creation-of-an-account#username-too-short'
  }

  # @see https://github.com/jdr-tools/accounts/wiki/Creation-of-an-account
  declare_premium_route('post', '/') do
    check_presence('username', 'password', 'password_confirmation', 'email')
    account = Arkaan::Account.new(account_parameters)
    if account.save
      halt 201, {message: 'created', item: Decorators::Account.new(account).to_h}.to_json
    else
      error_key = account.errors.messages.keys.first
      error = account.errors.messages[error_key].first
      url = @@docs["#{error_key}.#{error}"]
      halt 400, {status: 400, field: error_key, error: error, docs: url}.to_json
    end
  end

  declare_route('get', '/own') do
    check_presence('session_id')
    session = Arkaan::Authentication::Session.where(token: params['session_id']).first
    if session.nil?
      halt 404, {
        status: 404,
        field: 'session_id',
        error: 'unknown',
        docs: 'https://github.com/jdr-tools/arkaan/wiki/Getting-own-profile-informations#session-id-not-found'
      }.to_json
    else
      halt 200,  {account: Decorators::Account.new(session.account).to_h}.to_json
    end
  end

  # @see https://github.com/jdr-tools/accounts/wiki/Obtaining-account-informations
  declare_route('get', '/:account_id') do
    account = Arkaan::Account.where(id: params[:account_id]).first
    if account.nil?
      halt 404, {
        status: 404,
        field: 'account_id',
        error: 'unknown',
        docs: 'https://github.com/jdr-tools/accounts/wiki/Obtaining-account-informations#not-found-404-errors'
      }.to_json
    else
      halt 200,  {account: Decorators::Account.new(account).to_h}.to_json
    end
  end

  declare_route('put', '/own') do
    check_presence('session_id')
    check_presence('password_confirmation') if params.has_key?('password')
    session = Arkaan::Authentication::Session.where(token: params['session_id']).first
    if session.nil?
      halt 404, {message: 'session_not_found'}.to_json
    else
      account = session.account
      if account.update_attributes(account_parameters)
        halt 200, {message: 'updated', item: Decorators::Account.new(account).to_h}.to_json
      else
      error_key = account.errors.messages.keys.first
      error = account.errors.messages[error_key].first
      url = @@docs["#{error_key}.#{error}"]
      halt 400, {status: 400, field: error_key, error: error, docs: url}.to_json
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

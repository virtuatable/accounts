# frozen_string_literal: true

# Main controller of the application, creating and destroying sessions.
# @author Vincent Courtois <courtois.vincent@outlook.com>
class SessionsController < Sinatra::Base

  post '/' do
    @parameters = JSON.parse(request.body.read.to_s) rescue {}

    if @parameters['token'].nil? || @parameters['username'].nil? || @parameters['password'].nil? || @parameters['app_key'].nil?
      status 400
      body({message: 'bad_request'}.to_json)
    else
      gateway = Arkaan::Monitoring::Gateway.where(token: @parameters['token']).first
      application = Arkaan::OAuth::Application.where(key: @parameters['app_key']).first
      account = Arkaan::Account.where(username: @parameters['username']).first
      password = @parameters['password']

      if application.nil?
        status 404
        body({message: 'application_not_found'}.to_json)
      elsif !application.premium?
        status 401
        body({message: 'application_not_authorized'}.to_json)
      elsif gateway.nil?
        status 404
        body({message: 'gateway_not_found'}.to_json)
      elsif account.nil?
        status 404
        body({message: 'account_not_found'}.to_json)
      elsif !Decorators::Account.new(account).match_password(password)
        status 403
        body({message: 'wrong_password'}.to_json)
      else
        session = account.sessions.create(token: SecureRandom.hex)
        status 201
        body({token: session.token, expiration: session.expiration}.to_json)
      end
    end
  end
end

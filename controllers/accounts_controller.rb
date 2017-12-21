# frozen_string_literal: true

# Main controller of the application, creating and destroying sessions.
# @author Vincent Courtois <courtois.vincent@outlook.com>
class AccountsController < Sinatra::Base

  post '/' do
    @parameters = JSON.parse(request.body.read.to_s) rescue {}

    ['token', 'app_key', 'username', 'password', 'password_confirmation', 'email'].each do |field|
      halt(400, {message: 'bad_request'}.to_json) if @parameters[field].nil?
    end

    application = Arkaan::OAuth::Application.where(key: @parameters.delete('app_key')).first
    gateway = Arkaan::Monitoring::Gateway.where(token: @parameters.delete('token')).first

    if application.nil?
      halt 404, {message: 'application_not_found'}.to_json
    elsif gateway.nil?
      halt 404, {message: 'gateway_not_found'}.to_json
    elsif !application.premium?
      halt 401, {message: 'application_not_authorized'}.to_json
    else
      account = Arkaan::Account.new(@parameters)
      if account.valid?
        account.save!
        halt 201, {message: 'created', account: Decorators::Account.new(account).to_h}.to_json
      else
        halt 422, {errors: account.errors.messages.values.flatten}.to_json
      end
    end
  end
end

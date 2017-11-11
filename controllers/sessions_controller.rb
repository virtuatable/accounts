class AccountsController < Sinatra::Base
  post '/' do
    if params[:key].nil? or params[:username].nil? or params[:encrypted_password].nil?
      status 400
      body({messgae: 'bad_request'}.to_json)
    else
      application = Arkaan::OAuth::Application.where(key: params[:key]).first
      account = Arkaan::Account.where(username: params[:username]).first

      if application.nil or not application.premium?
        status 403
        body({message: 'application_not_authorized'}.to_json)
      elsif account.nil?
        status 404
        body({message: 'account_not_found'}.to_json)
      else
        
      end
    end
  end
end
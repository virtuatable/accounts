require 'bundler'
Bundler.require(ENV['RACK_ENV'].to_sym || :development)

service = Virtuatable::Application.load!('accounts')

run Controllers::Accounts
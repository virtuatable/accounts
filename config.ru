require 'bundler'
Bundler.require(ENV['RACK_ENV'].to_sym || :development)

Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

require './decorators/account.rb'
require './controllers/accounts_controller.rb'

service = Arkaan::Monitoring::Service.where(key: 'accounts').first

map(service ? service.path : '/accounts') { run AccountsController.new }

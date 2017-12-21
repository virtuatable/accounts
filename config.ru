require 'bundler'
Bundler.require(ENV['RACK_ENV'].to_sym || :development)

Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

require './decorators/account.rb'
require './controllers/accounts_controller.rb'
require './utils/seeder.rb'

service = Utils::Seeder.instance.create_service('accounts')

map(service.path) { run AccountsController.new }

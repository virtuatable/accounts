require 'bundler'
Bundler.require(ENV['RACK_ENV'].to_sym || :development)

Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

require './decorators/account.rb'
require './controllers/sessions_controller.rb'

service = Arkaan::Monitoring::Service.where(key: 'accounts').first

map(service ? service.path : '/sessions') { run SessionsController.new }

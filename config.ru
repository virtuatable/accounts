require 'bundler'
Bundler.require(ENV['RACK_ENV'].to_sym || :development)

Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

require './decorators/session.rb'
require './controllers/sessions_controller.rb'
require './utils/seeder.rb'

service = Utils::Seeder.instance.create_service('sessions')

map(service.path) { run SessionsController.new }

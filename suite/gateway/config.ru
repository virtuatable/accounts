require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'] || :development)

Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

require './lib/service_decorator.rb'
require './lib/service_controller.rb'

Arkaan::Monitoring::Service.all.each do |service|
  map(service.path) { run ServiceController.new(service) }
end
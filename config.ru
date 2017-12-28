require 'bundler'
Bundler.require(ENV['RACK_ENV'].to_sym || :development)

micro_service = Arkaan::Utils::MicroService.new(name: 'accounts', root: File.dirname(__FILE__)).load!

map(service.path) { run AccountsController.new }

require 'bundler'
Bundler.require :test

SimpleCov.start do
  add_filter File.join('spec', '*')
end

require File.join(File.dirname(__FILE__), '..', 'decorators', 'account.rb')
require File.join(File.dirname(__FILE__), '..', 'controllers', 'accounts_controller.rb')
require File.join(File.dirname(__FILE__), '..', 'utils', 'seeder.rb')

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each do |filename|
  require filename
end

Dir[File.join(File.dirname(__FILE__), 'shared', '**', '*.rb')].each do |filename|
  require filename
end
require 'bundler'
Bundler.require :test

service = Virtuatable::Application.load_tests!('accounts')
require 'arkaan'
require 'mongoid'

task default: %w(db:seed)

namespace :db do
  task :seed do
    Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

    unless Arkaan::Account.where(username: 'Babausse').exists?
      Arkaan::Account.create!(
        username: 'Babausse',
        password: ENV['INIT_PASSWORD'],
        password_confirmation: ENV['INIT_PASSWORD'],
        email: 'courtois.vincent@outlook.com')
    end
  end
end
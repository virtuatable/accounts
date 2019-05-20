lock '~> 3.11.0'

set :application, 'virtuatable-accounts'
set :deploy_to, '/var/www/accounts'
set :repo_url, 'git@github.com:jdr-tools/accounts.git'
set :branch, 'master'

append :linked_files, 'config/mongoid.yml'
append :linked_files, '.env'
append :linked_dirs, 'bundle'
append :linked_dirs, 'log'
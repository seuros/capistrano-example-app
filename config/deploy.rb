require 'dotenv'
Dotenv.load

set :application, "sample_app"
set :repo_url, "git@github.com:seuros/capistrano-example-app.git"

server ENV.fetch('TESTING_SERVER'), user: "deploy", roles: %w{app web worker}

set :deploy_to, -> { "/home/deploy/#{fetch(:stage)}" }
set :branch, :main

append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", ".bundle"

## This will run sidekiq and puma with production environment
set :rails_env, 'production'

# rbenv configuration
set :rbenv_type, :user
set :rbenv_ruby, '3.4.4'
set :rbenv_path, '$HOME/.rbenv'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails puma pumactl sidekiq sidekiqctl}
set :rbenv_roles, :all # default value

# bundler configuration
set :bundle_path, -> { shared_path.join('bundle') }
set :bundle_flags, '--deployment --quiet'
set :bundle_without, %w{development test}.join(' ')
set :bundle_bins, %w{sidekiq sidekiqctl}

# Sidekiq configuration
set :sidekiq_use_login_shell, true

# Puma configuration
set :puma_use_login_shell, true
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"

set :ssh_options, verify_host_key: :never
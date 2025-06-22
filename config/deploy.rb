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
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails puma pumactl sidekiq sidekiqctl}

set :ssh_options, verify_host_key: :never
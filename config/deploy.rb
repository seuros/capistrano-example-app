require 'dotenv'
Dotenv.load

set :application, "sample_app"
set :repo_url, "git@github.com:seuros/capistrano-example-app.git"

server ENV.fetch('TESTING_SERVER'), user: "deploy", roles: %w{app web}

set :deploy_to, -> { "/home/deploy/#{fetch(:stage)}" }
set :branch, :main

append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", ".bundle"

## This will run sidekiq and puma with production environment
set :rails_env, 'production'

set :ssh_options, verify_host_key: :never
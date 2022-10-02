## This stage will set environment variables from .env.example file and /etc/environment

set :service_unit_env_files, %W[/etc/environment #{current_path}/.env.example]
set :service_unit_env_vars, %w[FOO=BAR BAR=FOO RAILS_ENV=production]
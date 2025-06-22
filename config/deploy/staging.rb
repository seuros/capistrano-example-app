# Staging deployment configuration
# Mirrors production but with debugging enabled

# Stage configuration
set :stage, :staging
set :rails_env, 'production'  # Use production Rails env for realistic testing

# Server configuration
server ENV.fetch('STAGING_SERVER', ENV.fetch('TESTING_SERVER')), 
  user: "deploy", 
  roles: %w{app web worker}

# Puma configuration (same as production but with debug options)
set :puma_bind, ["unix://#{shared_path}/tmp/sockets/puma.sock", "tcp://127.0.0.1:9293"]
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{shared_path}/log/puma.log"
set :puma_error_log, "#{shared_path}/log/puma_error.log"
set :puma_preload_app, true
set :puma_workers, 2  # Less workers for staging
set :puma_threads, [0, 8]  # Less threads for staging
set :puma_init_active_record, true
set :puma_service_unit_type, :notify
set :puma_systemctl_user, :user

# Sidekiq configuration (single process for staging)
set :sidekiq_config_files, %w[sidekiq.yml]
set :sidekiq_env, 'production'
set :sidekiq_log, "#{shared_path}/log/sidekiq.log"
set :sidekiq_error_log, "#{shared_path}/log/sidekiq_error.log"
set :sidekiq_systemctl_user, :user
set :sidekiq_service_unit_env_vars, ["MALLOC_ARENA_MAX=2", "VERBOSE=1"]

# Enable deployment tracking in staging
set :sidekiq_mark_deploy, true
set :sidekiq_deploy_label, -> { "staging-#{fetch(:current_revision, 'unknown')[0..6]}" }

# Linked files and directories
append :linked_files, '.env.staging', 'config/database.yml', 'config/master.key'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads', 'storage'

# Keep fewer releases in staging
set :keep_releases, 3

# Bundle configuration
set :bundle_jobs, 2
set :bundle_without, %w{development test}.join(' ')

# Verbose output for debugging
set :format, :pretty
set :log_level, :debug

# SSH options
set :ssh_options, {
  keys: %w(~/.ssh/id_rsa),
  forward_agent: true,
  auth_methods: %w(publickey),
  verify_host_key: :accept_new_or_local_tunnel
}
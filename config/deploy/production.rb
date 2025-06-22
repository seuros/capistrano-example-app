# Production deployment configuration with best practices

# Stage configuration
set :stage, :production
set :rails_env, 'production'

# Server configuration
server ENV.fetch('TESTING_SERVER'), user: "deploy", roles: %w{app web worker}

# Optional: Second server for load balancing or dedicated workers
if ENV['TESTING_SERVER2'] && !ENV['TESTING_SERVER2'].empty?
  server ENV['TESTING_SERVER2'], user: "deploy", roles: %w{worker}, 
    sidekiq_config_files: %w[sidekiq-process2.yml]
end

# Puma configuration
set :puma_bind, ["unix://#{shared_path}/tmp/sockets/puma.sock", "tcp://127.0.0.1:9292"]
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{shared_path}/log/puma.log"
set :puma_error_log, "#{shared_path}/log/puma_error.log"
set :puma_preload_app, true
set :puma_workers, -> { [2, (Etc.nprocessors * 1.5).ceil].max }
set :puma_init_active_record, true
set :puma_service_unit_type, :notify  # Uses sd_notify gem
set :puma_systemctl_user, :user      # User-level systemd service
set :puma_enable_socket_service, true # Enable socket activation

# Sidekiq configuration
set :sidekiq_config_files, %w[sidekiq.yml sidekiq-process2.yml]
set :sidekiq_env, 'production'
set :sidekiq_log, "#{shared_path}/log/sidekiq.log"
set :sidekiq_error_log, "#{shared_path}/log/sidekiq_error.log"
set :sidekiq_systemctl_user, :user    # User-level systemd service
set :sidekiq_service_unit_env_files, ["#{shared_path}/.env.production"]
set :sidekiq_service_unit_env_vars, ["MALLOC_ARENA_MAX=2"] # Memory optimization

# Deployment tracking for Sidekiq 7+
set :sidekiq_mark_deploy, true
set :sidekiq_deploy_label, -> { "#{fetch(:stage)}-#{fetch(:current_revision, 'unknown')[0..6]}" }

# Linked files and directories
append :linked_files, '.env.production', 'config/database.yml', 'config/master.key'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads', 'storage'

# Keep last 5 releases
set :keep_releases, 5

# Bundle configuration
set :bundle_jobs, 4
set :bundle_without, %w{development test}.join(' ')
set :bundle_flags, '--deployment --quiet'
set :bundle_path, -> { shared_path.join('bundle') }
set :bundle_binstubs, -> { shared_path.join('bin') }

# Asset compilation
set :assets_roles, [:web, :app]
set :assets_prefix, 'assets'

# Maintenance mode
set :maintenance_template_path, File.expand_path("../../templates/maintenance.html.erb", __FILE__)

# SSH options for production
set :ssh_options, {
  keys: %w(~/.ssh/id_rsa),
  forward_agent: true,
  auth_methods: %w(publickey),
  verify_host_key: :never
}
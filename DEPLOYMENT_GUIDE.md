# Capistrano Deployment Guide with Puma & Sidekiq

This guide demonstrates how to deploy a Rails 8.0 application using Capistrano with Puma and Sidekiq managed by systemd.

## Prerequisites

### Local Development Machine
- Ruby 3.4.4+ 
- Bundler 2.0+
- Git
- SSH key pair for deployment

### Target Servers
- Ubuntu 22.04 LTS (or similar)
- Redis 7.0+ (required for Sidekiq 7.0+)
- PostgreSQL 14+ (or your preferred database)
- Nginx (for reverse proxy)
- rbenv with Ruby 3.4.4 installed

## Step 1: Gemfile Configuration

Add these gems to your `Gemfile`:

```ruby
# Deployment
group :development do
  gem "capistrano", require: false
  gem "capistrano-rbenv", require: false
  gem "capistrano-bundler", require: false
  gem "capistrano-sidekiq", require: false
  gem "capistrano3-puma", require: false
end

# Application server
gem "puma", "~> 6.0"

# Background jobs
gem "sidekiq", "~> 7.0"

# For systemd notify support (production)
group :production do
  gem "sd_notify"
end
```

## Step 2: Capfile Setup

Create or update your `Capfile`:

```ruby
# Load DSL and set up stages
require "capistrano/setup"
require "capistrano/deploy"

# Load the SCM plugin
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Load rbenv support (must be before bundler)
require 'capistrano/rbenv'
require 'capistrano/bundler'

# Load Sidekiq and Puma plugins
require 'capistrano/sidekiq'
install_plugin Capistrano::Sidekiq
install_plugin Capistrano::Sidekiq::Systemd

require 'capistrano/puma'
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Systemd

# Load custom tasks
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
```

## Step 3: Deploy Configuration

Create `config/deploy.rb`:

```ruby
# Application settings
set :application, "your_app_name"
set :repo_url, "git@github.com:yourusername/yourapp.git"
set :deploy_to, -> { "/home/deploy/#{fetch(:stage)}" }
set :branch, :main

# Linked files and directories
append :linked_files, '.env.production', 'config/database.yml', 'config/master.key'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads', 'storage'

# Rails environment
set :rails_env, 'production'

# rbenv configuration
set :rbenv_type, :user
set :rbenv_ruby, '3.4.4'
set :rbenv_path, '$HOME/.rbenv'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails puma pumactl sidekiq sidekiqctl}
set :rbenv_roles, :all

# Bundler configuration
set :bundle_path, -> { shared_path.join('bundle') }
set :bundle_flags, '--deployment --quiet'
set :bundle_without, %w{development test}.join(' ')
set :bundle_bins, %w{sidekiq sidekiqctl}

# Sidekiq configuration
set :sidekiq_use_login_shell, true
set :sidekiq_service_unit_env_files, -> { ["#{shared_path}/.env.production"] }

# Puma configuration
set :puma_use_login_shell, true
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_service_unit_type, :notify  # Uses sd_notify gem

# Keep last 5 releases
set :keep_releases, 5
```

## Step 4: Stage Configuration

Create `config/deploy/production.rb`:

```ruby
# Server configuration
server ENV.fetch('PRODUCTION_SERVER'), user: "deploy", roles: %w{app web worker}

# Optional: Second server for dedicated workers
if ENV['PRODUCTION_SERVER2']
  server ENV['PRODUCTION_SERVER2'], user: "deploy", roles: %w{worker}, 
    sidekiq_config_files: %w[sidekiq-process2.yml]
end

# Stage-specific settings
set :stage, :production
set :rails_env, 'production'

# Puma configuration
set :puma_workers, -> { [2, Etc.nprocessors].max }
set :puma_threads, [0, 16]
set :puma_preload_app, true
set :puma_init_active_record, true

# Sidekiq configuration  
set :sidekiq_config_files, %w[sidekiq.yml]
set :sidekiq_env, 'production'
```

## Step 5: Environment Variables

Create `.env` file for local deployment configuration:

```bash
# Server IPs
PRODUCTION_SERVER=your.server.ip
PRODUCTION_SERVER2=your.second.server.ip  # Optional

# Database
DATABASE_URL=postgresql://deploy:password@localhost/yourapp_production

# Redis
REDIS_URL=redis://localhost:6379/0

# Rails
SECRET_KEY_BASE=your-secret-key-base
RAILS_MASTER_KEY=your-master-key
```

## Step 6: Server Setup

### Install Redis 7+

```bash
# Add Redis repository
curl -fsSL https://packages.redis.io/gpg | sudo apt-key add -
echo "deb https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
sudo apt-get update
sudo apt-get install redis
```

### Install rbenv and Ruby

```bash
# As deploy user
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Add to ~/.bashrc
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

# Install Ruby
rbenv install 3.4.4
rbenv global 3.4.4
gem install bundler
```

## Step 7: Initial Deployment

```bash
# Check deployment prerequisites
bundle exec cap production deploy:check

# Install systemd services (only needed once)
bundle exec cap production puma:install
bundle exec cap production sidekiq:install

# Deploy the application
bundle exec cap production deploy
```

## Step 8: Systemd Service Management

### Puma Commands
```bash
cap production puma:start       # Start Puma
cap production puma:stop        # Stop Puma
cap production puma:restart     # Restart Puma
cap production puma:status      # Check status
```

### Sidekiq Commands
```bash
cap production sidekiq:start    # Start Sidekiq
cap production sidekiq:stop     # Stop Sidekiq (graceful)
cap production sidekiq:restart  # Restart Sidekiq
cap production sidekiq:quiet    # Stop fetching new jobs
cap production sidekiq:status   # Check status
```

## Step 9: Nginx Configuration

Example Nginx configuration for Puma:

```nginx
upstream app_puma {
  server unix:///home/deploy/production/shared/tmp/sockets/puma.sock;
}

server {
  listen 80;
  server_name your-domain.com;

  root /home/deploy/production/current/public;

  location / {
    try_files $uri @app;
  }

  location @app {
    proxy_pass http://app_puma;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
  }

  location ~ ^/(assets|packs)/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }
}
```

## Troubleshooting

### Check Service Logs
```bash
# Puma logs
ssh deploy@server 'journalctl --user -u sample_app_puma_production -n 100'

# Sidekiq logs  
ssh deploy@server 'journalctl --user -u sample_app_sidekiq_production -n 100'
```

### Common Issues

1. **Redis version mismatch**: Sidekiq 7.0 requires Redis 6.2+. Install Redis 7+ from the official repository.

2. **Bundle command not found**: Ensure rbenv is properly configured and the Capfile loads capistrano-rbenv before capistrano-bundler.

3. **Systemd service fails to start**: Check that `:sidekiq_use_login_shell` and `:puma_use_login_shell` are set to `true` for rbenv environments.

4. **rails_app_version gem errors**: Run `bundle exec rake app:version:config` to generate the required configuration file.

## Advanced Configuration

### Multiple Sidekiq Processes

Configure multiple Sidekiq processes by creating separate config files:

```yaml
# config/sidekiq.yml
:concurrency: 5
:queues:
  - default
  - mailers

# config/sidekiq-process2.yml  
:concurrency: 3
:queues:
  - low_priority
```

Then in your stage file:
```ruby
set :sidekiq_config_files, %w[sidekiq.yml sidekiq-process2.yml]
```

### Environment Variables

Load environment files in systemd services:
```ruby
set :sidekiq_service_unit_env_files, ["#{shared_path}/.env.production"]
set :puma_service_unit_env_files, ["#{shared_path}/.env.production"]
```

## Security Considerations

1. Use SSH key authentication only (disable password auth)
2. Configure firewall rules (ufw or iptables)
3. Use environment files for secrets (never commit them)
4. Set up SSL certificates with Let's Encrypt
5. Configure fail2ban for SSH protection
6. Use strong database passwords
7. Restrict Redis to localhost only

## Performance Tuning

### Puma
- Set workers based on CPU cores: `[2, Etc.nprocessors].max`
- Use `preload_app` for memory efficiency
- Enable `puma_init_active_record` for database connections

### Sidekiq
- Tune concurrency based on workload
- Use separate queues for different priorities
- Monitor memory usage with `MALLOC_ARENA_MAX=2`

## Monitoring

Consider integrating:
- Application Performance Monitoring (APM): New Relic, DataDog, Scout
- Error tracking: Sentry, Rollbar, Bugsnag
- Log aggregation: ELK stack, Papertrail
- Uptime monitoring: UptimeRobot, Pingdom

## References

- [Capistrano Documentation](https://capistranorb.com/)
- [capistrano3-puma](https://github.com/seuros/capistrano-puma)
- [capistrano-sidekiq](https://github.com/seuros/capistrano-sidekiq)
- [Puma Documentation](https://puma.io/)
- [Sidekiq Documentation](https://sidekiq.org/)
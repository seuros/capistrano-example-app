# Quick Reference - Capistrano Puma/Sidekiq

## Deployment Commands

```bash
# First time setup
cap production deploy:check
cap production puma:install
cap production sidekiq:install

# Regular deployment
cap production deploy

# Rollback
cap production deploy:rollback
```

## Service Management

### Puma
```bash
cap production puma:start
cap production puma:stop
cap production puma:restart    # Hard restart
cap production puma:reload     # Soft reload
cap production puma:status
```

### Sidekiq
```bash
cap production sidekiq:start
cap production sidekiq:stop
cap production sidekiq:restart
cap production sidekiq:quiet   # Stop accepting new jobs
cap production sidekiq:status
```

## Environments

- **simple** - Basic setup, no socket activation
- **production** - Full features, socket activation, multiple workers
- **staging** - Like production but with debug logging
- **multi_process** - Multiple Sidekiq processes across servers
- **root** - System-wide services (requires sudo)
- **with_env** - Custom environment variables

## Configuration Files

### Puma
- `config/puma.rb` - Default configuration
- `config/puma/production.rb` - Production-specific config

### Sidekiq
- `config/sidekiq.yml` - Main process configuration
- `config/sidekiq-process2.yml` - Heavy jobs process

### Deployment
- `config/deploy.rb` - Base configuration
- `config/deploy/*.rb` - Stage-specific configs

## Key Settings

### deploy.rb
```ruby
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_workers, 2
set :sidekiq_config_files, %w[sidekiq.yml]
set :sidekiq_systemctl_user, :user  # or :system
```

### Environment Variables
```bash
WEB_CONCURRENCY=2          # Puma workers
RAILS_MAX_THREADS=16       # Puma threads
SIDEKIQ_CONCURRENCY=25     # Sidekiq threads
MALLOC_ARENA_MAX=2         # Memory optimization
```

## Logs

```bash
# View logs
journalctl -u sample_app_puma_production -f
journalctl -u sample_app_sidekiq_production -f

# Log files
/home/deploy/production/shared/log/puma.log
/home/deploy/production/shared/log/sidekiq.log
```

## Troubleshooting

```bash
# Check service status
systemctl --user status sample_app_puma_production
systemctl --user status sample_app_sidekiq_production*

# Enable lingering (for user services)
sudo loginctl enable-linger deploy

# Fix socket permissions
chmod 755 /home/deploy/production/shared/tmp/sockets

# Verify bundle
cd /home/deploy/production/current && bundle check
```
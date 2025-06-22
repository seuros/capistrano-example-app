# Testing Guide for Capistrano Puma/Sidekiq Integration

This guide covers testing the capistrano-puma and capistrano-sidekiq gems using this example application.

## Prerequisites

1. A test server (Ubuntu/Debian recommended) with:
   - SSH access configured
   - Ruby installed (matching `.ruby-version`)
   - PostgreSQL and Redis installed
   - systemd available
   - A deploy user with sudo access (for system services) or regular user (for user services)

2. Local development environment with:
   - Ruby matching the server version
   - Bundler installed
   - SSH key added to the server

## Initial Setup

### 1. Configure Environment

```bash
# Copy environment templates
cp .env.example .env
cp .env.production.example .env.production
cp .env.staging.example .env.staging

# Edit .env with your server IPs
TESTING_SERVER=192.168.1.100      # Your primary server
TESTING_SERVER2=192.168.1.101     # Optional secondary server

# For local gem development
USE_LOCAL_GEMS=true
```

### 2. Switch to Local Gems (for development)

```bash
# Use local gem versions
bin/use_local_gems on

# Verify it's using local paths
bundle show capistrano3-puma
bundle show capistrano-sidekiq
```

### 3. Prepare Server

```bash
# Setup deployment structure
cap production deploy:check

# Upload environment file
cap production deploy:upload_env
```

## Testing Scenarios

### Scenario 1: Basic Deployment (Simple Environment)

Tests basic Puma deployment with systemd.

```bash
# Deploy using simple configuration
cap simple deploy

# This tests:
# - Basic Puma deployment
# - Simple service type (no sd_notify)
# - Single Sidekiq process
```

### Scenario 2: Production Deployment

Tests full production setup with all features.

```bash
# First time setup - install systemd services
cap production puma:install
cap production sidekiq:install

# Deploy application
cap production deploy

# This tests:
# - Puma with socket activation
# - Multiple workers and threads
# - Systemd notify type
# - Multiple Sidekiq processes
# - Zero-downtime deployment
```

### Scenario 3: Multi-Server Deployment

Tests deployment across multiple servers.

```bash
# Requires TESTING_SERVER2 to be set
cap multi_process deploy

# This tests:
# - Different Sidekiq processes on different servers
# - Server-specific configurations
# - Load distribution
```

### Scenario 4: Root vs User Services

Tests different systemd integration modes.

```bash
# Deploy with root/system services
cap root deploy

# This tests:
# - System-wide systemd services
# - Proper sudo handling
# - Service permissions
```

### Scenario 5: Environment Variables

Tests environment variable handling.

```bash
# Deploy with custom environment
cap with_env deploy

# This tests:
# - Environment file loading
# - Custom environment variables
# - Service unit environment configuration
```

## Service Management Commands

### Puma Commands

```bash
# Service control
cap production puma:start
cap production puma:stop
cap production puma:restart
cap production puma:reload        # Zero-downtime reload
cap production puma:smart_restart # Phased restart
cap production puma:status

# Socket management (if enabled)
cap production puma:stop_socket
cap production puma:restart_socket

# Systemd management
cap production puma:enable   # Enable on boot
cap production puma:disable  # Disable on boot
```

### Sidekiq Commands

```bash
# Service control
cap production sidekiq:start
cap production sidekiq:stop
cap production sidekiq:restart
cap production sidekiq:quiet     # Stop accepting new jobs
cap production sidekiq:status

# Systemd management
cap production sidekiq:install   # Install service files
cap production sidekiq:uninstall # Remove service files
cap production sidekiq:enable    # Enable on boot
cap production sidekiq:disable   # Disable on boot
```

## Monitoring and Debugging

### View Logs

```bash
# Puma logs
ssh deploy@server "journalctl -u sample_app_puma_production -f"
ssh deploy@server "tail -f /home/deploy/production/shared/log/puma*.log"

# Sidekiq logs
ssh deploy@server "journalctl -u sample_app_sidekiq_production -f"
ssh deploy@server "tail -f /home/deploy/production/shared/log/sidekiq*.log"

# For multiple Sidekiq processes
ssh deploy@server "journalctl -u 'sample_app_sidekiq_production*' -f"
```

### Check Service Status

```bash
# System services
ssh deploy@server "sudo systemctl status sample_app_puma_production"
ssh deploy@server "sudo systemctl status sample_app_sidekiq_production*"

# User services
ssh deploy@server "systemctl --user status sample_app_puma_production"
ssh deploy@server "systemctl --user status sample_app_sidekiq_production*"
```

### Debug Failed Deployments

```bash
# Check why a service failed
ssh deploy@server "journalctl -u sample_app_puma_production -n 100 --no-pager"

# Check systemd service files
ssh deploy@server "systemctl --user cat sample_app_puma_production"
ssh deploy@server "systemctl --user cat sample_app_sidekiq_production"

# Verify file permissions
ssh deploy@server "ls -la /home/deploy/production/current/"
ssh deploy@server "ls -la /home/deploy/production/shared/tmp/sockets/"
```

## Configuration Testing

### Test Puma Configuration

```bash
# Validate Puma config locally
RAILS_ENV=production bundle exec puma -C config/puma/production.rb --debug

# Test on server
ssh deploy@server "cd /home/deploy/production/current && RAILS_ENV=production bundle exec puma -C config/puma.rb -t"
```

### Test Sidekiq Configuration

```bash
# Validate Sidekiq config locally
bundle exec sidekiq -C config/sidekiq.yml --dry-run

# Test on server
ssh deploy@server "cd /home/deploy/production/current && bundle exec sidekiq -C config/sidekiq.yml --dry-run"
```

## Performance Testing

### Load Testing with Apache Bench

```bash
# Test Puma performance
ab -n 1000 -c 10 http://server:9292/
ab -n 1000 -c 50 http://server:9292/

# Monitor during load test
ssh deploy@server "htop"
ssh deploy@server "journalctl -u sample_app_puma_production -f"
```

### Sidekiq Performance

```ruby
# Create test job in Rails console
100.times { TestJob.perform_later }

# Monitor processing
ssh deploy@server "watch 'systemctl --user status sample_app_sidekiq_production*'"
```

## Rollback Testing

```bash
# Deploy and then rollback
cap production deploy
cap production deploy:rollback

# Verify services still running
cap production puma:status
cap production sidekiq:status
```

## Common Issues and Solutions

### 1. Service Won't Start

```bash
# Check for port conflicts
ssh deploy@server "sudo lsof -i :9292"
ssh deploy@server "ls -la /home/deploy/production/shared/tmp/sockets/"

# Check bundle installation
ssh deploy@server "cd /home/deploy/production/current && bundle check"
```

### 2. Permission Errors

```bash
# Fix socket directory permissions
ssh deploy@server "mkdir -p /home/deploy/production/shared/tmp/sockets"
ssh deploy@server "chmod 755 /home/deploy/production/shared/tmp/sockets"

# Enable lingering for user services
ssh deploy@server "sudo loginctl enable-linger deploy"
```

### 3. Memory Issues

```bash
# Monitor memory usage
ssh deploy@server "free -h"
ssh deploy@server "ps aux | grep -E 'puma|sidekiq' | grep -v grep"

# Adjust worker counts in production.rb or environment variables
```

## Cleanup

```bash
# Remove test deployment
cap production puma:stop
cap production sidekiq:stop
cap production puma:uninstall
cap production sidekiq:uninstall

# Remove deployment directory
ssh deploy@server "rm -rf /home/deploy/production"
```

## Best Practices Validated

This test suite validates:

1. ✅ Zero-downtime deployments
2. ✅ Automatic service restart on failure
3. ✅ Proper systemd integration
4. ✅ Environment variable management
5. ✅ Multiple process support
6. ✅ Socket activation for Puma
7. ✅ Graceful shutdowns
8. ✅ Memory optimization
9. ✅ Log rotation handling
10. ✅ Multi-server deployments
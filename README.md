# Capistrano Example App

A minimal Rails 8.0 application demonstrating deployment with Capistrano, Puma, and Sidekiq using systemd.

## Overview

This example application shows best practices for deploying Ruby on Rails applications with:
- **Capistrano 3** for deployment automation
- **Puma 6** as the web server
- **Sidekiq 7** for background job processing
- **Systemd** for service management
- **rbenv** for Ruby version management

## Requirements

- Ruby 3.4.4
- Rails 8.0.0
- Redis 7.0+ (required for Sidekiq 7.0)
- PostgreSQL 14+

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/seuros/capistrano-example-app.git
cd capistrano-example-app
```

2. Install dependencies:
```bash
bundle install
```

3. Configure deployment servers:
```bash
# Create .env file with your server details
cat > .env << EOF
TESTING_SERVER=your.server.ip       # Primary server
TESTING_SERVER2=your.server2.ip     # Optional: second server for workers
EOF
```

4. Deploy:
```bash
# Check deployment configuration
cap production deploy:check

# Install systemd services (first time only)
cap production puma:install
cap production sidekiq:install

# Deploy application
cap production deploy
```

## Documentation

See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for comprehensive deployment instructions including:
- Detailed server setup
- rbenv and Ruby installation
- Redis 7+ installation
- Nginx configuration
- Troubleshooting guide
- Performance tuning tips

## Testing Infrastructure

This repository includes Terraform configuration for quickly spinning up test servers on Hetzner Cloud:

```bash
cd terraform
./deploy_test.sh
```

## Related Projects

This example app demonstrates the usage of:
- [capistrano3-puma](https://github.com/seuros/capistrano-puma) - Puma integration for Capistrano 3
- [capistrano-sidekiq](https://github.com/seuros/capistrano-sidekiq) - Sidekiq integration for Capistrano 3

## Notes

- Currently tested on Ubuntu 22.04 LTS
- Requires Redis 7.0+ for Sidekiq 7.0 compatibility
- Uses user-level systemd services for better security
- Pull requests welcome for other OS support

## License

MIT License

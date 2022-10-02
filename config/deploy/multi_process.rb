set :sidekiq_config_files, %w[sidekiq.yml sidekiq-process2.yml]

server ENV.fetch('TESTING_SERVER'), user: "ubuntu", roles: %w{app web worker}

## Server 2 will have only sidekiq-process2, if you want to append to the initial list use fetch(:sidekiq_config_files).push('others.yml')
server ENV.fetch('TESTING_SERVER2'), user: "ubuntu", roles: %w{worker}, sidekiq_config_files: %w[sidekiq-process2.yml]
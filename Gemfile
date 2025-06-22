source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "dotenv-rails", require: "dotenv/load"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
rails_version = "~> 8.0.0"
gem "railties", rails_version
gem "actionpack", rails_version
gem "puma", "~> 6.0"
group :production do
  gem "sd_notify" ## This is for systemd
end
gem "sidekiq", "~> 7.0"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

gem "rails_app_version"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'maxitest'
  gem 'minitest-reporters'
  gem 'minitest-spec-rails'
  gem 'minitest-stackprof'
  gem 'mocha'
  gem 'ruby-prof', require: false
  gem 'selenium-webdriver'
  gem 'shoulda', '4.0.0'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
  gem 'simplecov-db', require: false
  gem 'database_cleaner', require: false
  gem 'stackprof', require: false
  gem 'test-prof'
  gem 'fabrication'
  gem 'timecop'
  gem 'trailblazer-test'
  gem 'vcr', require: false
  gem 'webmock', require: false
end

group :development do
  gem "capistrano", require: false
  gem "capistrano-rbenv", require: false
  gem "capistrano-bundler", require: false
  gem "capistrano-sidekiq", github: "seuros/capistrano-sidekiq", require: false
  gem "capistrano3-puma", github: "seuros/capistrano-puma", require: false
end
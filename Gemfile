source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "dotenv-rails", require: "dotenv/rails-now"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
RAILS_VERSION = "~> 7.0.4"
gem "railties", RAILS_VERSION
gem "actionpack", RAILS_VERSION
gem "puma", "~> 5.1"
group :production do
  gem "sd_notify" ## This is for systemd
end
gem "sidekiq", "~> 6.2"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  gem "capistrano-sidekiq", '>= 3.0.0.alpha.1', require: false
  gem "capistrano3-puma", '>= 6.0.0.alpha.4', require: false
end


source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "dotenv-rails", require: "dotenv/rails-now"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
rails_version = "~> 7.1"
gem "railties", rails_version
gem "actionpack", rails_version
gem "puma"
group :production do
  gem "sd_notify" ## This is for systemd
end
gem "sidekiq"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  gem "capistrano-sidekiq", require: false, github: "seuros/capistrano-sidekiq"
  gem "capistrano3-puma", require: false, github: "seuros/capistrano-puma"
end


# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

# if ENV['COVERAGE']
#   require 'simplecov'
#
#   if ENV['CI']
#     puts 'CI detected, using JSON formatter and lcov'
#     require 'simplecov_json_formatter'
#     require_relative 'support/lcov_formatter'
#     SimpleCov.formatters = [SimpleCov::Formatter::JSONFormatter, SimpleCov::Formatter::LcovFormatter]
#   else
#     require 'simplecov-console'
#     require 'simplecov-html'
#     require 'simplecov-db'
#     SimpleCov::Formatter::Console.max_rows = 50
#     SimpleCov.formatters = [
#       SimpleCov::Formatter::Console,
#       SimpleCov::Formatter::HTMLFormatter,
#       SimpleCov::Formatter::DBFormatter
#     ]
#   end
#
#   SimpleCov.profiles.define 'trailblazer' do
#     load_profile 'rails'
#   end
#   SimpleCov.start 'trailblazer' do
#     enable_coverage :branch
#     add_group 'Cells', 'app/cells'
#     add_group 'Queries', 'app/queries'
#     add_group 'Representers' do |src_file|
#       src_file.filename.end_with?('index_representer.rb')
#     end
#     add_group 'Contracts' do |src_file|
#       ## file will be in a contracts folder
#       src_file.filename.include?('contract')
#     end
#     add_group 'Operations' do |src_file|
#       ## file will be in a operations folder
#       src_file.filename.include?('operation')
#     end
#     add_group 'Finders' do |src_file|
#       ## file will be in a finders folder
#       src_file.filename.include?('finder')
#     end
#     add_group 'Uploaders', 'app/uploaders'
#     add_group 'Utils', 'app/utils'
#   end
# end

require_relative '../config/environment'

ENV["MAXITEST_NO_INTERRUPT"] = "1"
require 'maxitest/autorun'
require 'rails/test_help'
require 'minitest-spec-rails'
require 'fabrication'
require 'vcr'
require 'mocha/minitest'

# require_relative 'support/json_reporter'
Minitest::Reporters.use!

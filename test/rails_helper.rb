# frozen_string_literal: true

require 'test_helper'
require 'shoulda-context'
require 'shoulda-matchers'
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :active_record
  end
end

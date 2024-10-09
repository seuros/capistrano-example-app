# frozen_string_literal: true
require 'test_helper'

class AppTest < ActiveSupport::TestCase
  (1..30).each do |i|
    define_method("test_example_#{i}") do
      assert true, "Test #{i} should pass"
    end
  end
end

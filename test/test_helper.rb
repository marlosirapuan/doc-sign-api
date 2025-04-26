ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"

require "rails/test_help"
require "minitest/reporters"

include ActionDispatch::TestProcess

Minitest::Reporters.use!(
  Minitest::Reporters::SpecReporter.new,
  ENV,
  Minitest.backtrace_filter
)

class ActiveSupport::TestCase
  # Setup fixtures for all tests
  fixtures :all
end

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'simplecov'
SimpleCov.start do
  add_filter "/features/"
end

# Simple assert function
def assert(condition, message = "Unknown reason")
  if condition
    return
  end
  raise message
end

require "teelogger"

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

# Simple assert function
def assert(condition, message = "Unknown reason")
  if condition
    return
  end
  raise message
end

require "teelogger"

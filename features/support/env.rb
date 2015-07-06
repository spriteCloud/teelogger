require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

# Simple assert function
def assert(condition, message = "Unknown reason")
  if not condition
    raise message
  end
end

require "teelogger"

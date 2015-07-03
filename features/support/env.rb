require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

begin
  require 'test/unit/assertions'
rescue LoadError
  require 'minitest/assertions'
end

require "teelogger"

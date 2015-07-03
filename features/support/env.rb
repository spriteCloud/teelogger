require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

begin
  require 'minitest/assertions'
rescue LoadError
  require 'test/unit/assertions'
end

require "teelogger"

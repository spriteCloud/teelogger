begin
  require 'test/unit/assertions'
rescue LoadError
  require 'minitest/assertions'
end

message = "test message"
io = nil
logger = nil

Given(/^I create a TeeLogger with default parameters$/) do
  logger = TeeLogger::TeeLogger.new
end

Given(/^I set the log level to "(.*?)"$/) do |level|
  logger.level = level
end

Given(/^I write a log message at log level "(.*?)"$/) do |level|
  meth = level.downcase.to_sym
  res = logger.send(meth, message)
end

Then(/^I expect the log message to appear on the screen$/) do
  puts "Can't test this; please check manually"
end

Then(/^I expect the log level "(.*?)" to have taken hold$/) do |level|
  meth = "#{level.downcase}?".to_sym
  res = logger.send(meth)

  assert res, "Log level not active!"
end


Given(/^I create a TeeLogger with an IO object$/) do
  io = StringIO.new
  logger = TeeLogger::TeeLogger.new io
end

Given(/^I create a TeeLogger with multiple loggers$/) do
  args = []
  3.times do
    args << StringIO.new
  end
  logger = TeeLogger::TeeLogger.new *args
end

Then(/^I expect the class to let me access all loggers like a hash$/) do
  assert (3 == logger.length), "Expected 3 loggers, got #{logger.length}"
  logger.each do |key, logger|
    assert logger.is_a?(Logger), "Found a non-Logger object."
  end
end

Then(/^I (.+) the log message to appear in the IO object$/) do |expectation|
  if expectation == 'expect'
    assert io.string.include?(message), "Test message '#{message}' not included in output."
  else
    assert (not io.string.include?(message)), "Test message '#{message}' included in output."
  end
end

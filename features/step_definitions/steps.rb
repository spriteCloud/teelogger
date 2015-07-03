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
  assert [TeeLogger::DEFAULT_FLUSH_INTERVAL] == logger.flush_interval, "Flush interval is not default: #{logger.flush_interval}"
end

Given(/^I set the flush_interval to "([^"]*)"$/) do |interval|
  i = interval.to_i
  logger.flush_interval = i
  assert [i] == logger.flush_interval, "Setting flush interval did not take: #{logger.flush_interval}"
end

level_set_exception = nil
Given(/^I set the log level to "(.*?)"$/) do |level|
  begin
    logger.level = level
    level_set_exception = nil
  rescue StandardError => err
    level_set_exception = err
  end
end

Given(/^I write a log message at log level "(.*?)"$/) do |level|
  meth = level.downcase.to_sym
  res = logger.send(meth, message)
end

Then(/^I expect the log message to appear on the screen$/) do
  puts "Can't test this; please check manually"
end

Then(/^I expect this to ([^ ]*?) ?raise an exception$/) do |mod|
  if mod.strip != "not"
    assert !level_set_exception.nil?, "Expected an exception, but none was raised."
  end
end

Then(/^I expect the log level to be "([^"]*)"$/) do |result|
  puts logger.level
  puts result
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^I expect the log level "(.*?)" to (.*?) taken hold$/) do |level, condition|
  meth = "#{level.downcase}?".to_sym
  res = logger.send(meth)
  logger.flush

  assert res, "Bad results!"
  if 'have' === condition
    assert res[0], "Log level not active!"
  else
    assert !res[0], "Log level is active!"
  end
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


Given(/^I log an exception$/) do
  begin
    raise "Some error"
  rescue StandardError => err
    message = "@@EXCEPTION@@"
    logger.exception(message, err)
  end
end

Then(/^I expect the log message to (.*?) in the IO object$/) do |appear|
  appear.strip!
  case appear
    when "appear"
      assert io.string.include?(message), "Test message '#{message}' not included in output."
    when "not appear"
      assert !io.string.include?(message), "Test message '#{message}' included in output, didn't expect that!"
    else
      raise "Not implemented: appear == '#{appear}'"
  end
end


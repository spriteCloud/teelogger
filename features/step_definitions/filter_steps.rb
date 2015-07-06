io = nil
logger = nil

Given(/^I create a TeeLogger for testing filters$/) do
  io = StringIO.new
  logger = TeeLogger::TeeLogger.new io
  assert [TeeLogger::DEFAULT_FLUSH_INTERVAL] == logger.flush_interval, "Flush interval is not default: #{logger.flush_interval}"
end

Given(/^I write a log message containing the word "([^"]*)"$/) do |word|
  # Log a string
  logger.error(word)
end

Given(/^I write a log message containing the word "([^"]*)" in an Array$/) do |word|
  # Log an Array
  logger.error([1, word, 3])
end

Given(/^I write a log message containing the value "([^"]*)" for the key "([^"]*)" in a Hash$/) do |value, key|
  # Log a Hash
  val = {
    1 => 2,
    2 => {
      key => value
    },
    3 => [
      'a', "#{key}=#{value}", 'b',
    ],
  }
  logger.error(val)
end

Given(/^I set filter words to include "([^"]*)"$/) do |filter_word|
  TeeLogger::Filter.filter_words = [filter_word]
end

Then(/^I expect the log message to ([^ ]* ?)contain the word "([^"]*)"$/) do |mod, word|
  mod = mod.strip
  message = io.string

  case mod
  when "not"
    assert !message.include?(word), "Log message contains '#{word}' when it must not!"
  else
    assert message.include?(word), "Log message does not contain '#{word}' when it should!"
  end
end



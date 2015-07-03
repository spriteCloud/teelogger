formatter = nil
result = nil

Given(/^I create a Formatter with "([^"]*)" in the format string$/) do |format|
  formatter = ::TeeLogger::Formatter.new(format)
end

Given(/^I call it with parameters "([^"]*)", "([^"]*)", "([^"]*)" and "([^"]*)"$/) do |severity, time, progname, message|
  # The time needs to be parsed to make some kind of sense; anything else
  # can just be passed through.
  t = Time.parse(time)
  result = formatter.call(severity, t, progname, message)
end

Then(/^I expect the result to match "([^"]*)"$/) do |expected|
  regex = Regexp.new("^#{expected}$")
  assert regex.match(result), "Expected to match '#{regex}' (#{expected}), but got '#{result}'"
end


io = nil
logger = nil
error = nil

Given(/^I create a TeeLogger for regression testing issues$/) do
  io = StringIO.new
  logger = TeeLogger::TeeLogger.new io
  assert [TeeLogger::DEFAULT_FLUSH_INTERVAL] == logger.flush_interval,
         "Flush interval is not default: #{logger.flush_interval}"
end

Given(/^I log complex data$/) do
  # Reduced data from issue #7
  data = {
    "status" => 200,
    "result" => {
      "id" => 123,
      "caps" => [
        {
          "first" => [42],
          "second" => ["some string"],
        },
      ],
    },
  }

  begin
    logger.error(data)
    error = nil
  rescue StandardError => err
    error = err
  end
end

Then(/^I expect there not to be an exception$/) do
  assert error.nil?, "Expected no error, but got: #{error}"
end

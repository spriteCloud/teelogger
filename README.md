# Teelogger

Mini wrapper around Ruby Logger for logging to multiple destinations.

## Installation

Add this line to your application's Gemfile:

    gem 'teelogger'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install teelogger

## Usage

 Behaves just like Ruby's Logger, and like a hash of String => Logger.

A typical use might be to log to STDOUT, but also to a file:

```ruby
log = TeeLogger.new(STDOUT, "filename.log")
log.level = Logger::WARN # applies to all outputs
log.level = "INFO"       # convenience shortcut
```

By using the instance as a hash, you can also set individual log levels
for individual loggers:

```ruby
log = TeeLogger.new(STDOUT, "filename.log")
log.each do |name, logger|
  if name.include?("filename.log")
    logger.level = "WARN"
  else
    logger.level = "DEBUG"
  end
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/teelogger/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

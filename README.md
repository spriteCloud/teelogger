# Teelogger

Mini wrapper around Ruby Logger for logging to multiple destinations.

[![Gem Version](https://badge.fury.io/rb/teelogger.svg)](http://badge.fury.io/rb/teelogger)
[![Build Status](https://travis-ci.org/spriteCloud/teelogger.svg?branch=master)](https://travis-ci.org/spriteCloud/teelogger)

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
require 'teelogger'

log = TeeLogger::TeeLogger.new(STDOUT, "filename.log")
log.level = Logger::WARN # applies to all outputs
log.level = "INFO"       # convenience shortcut
```

By using the instance as a hash, you can also set individual log levels
for individual loggers:

```ruby
require 'teelogger'

log = TeeLogger::TeeLogger.new(STDOUT, "filename.log")
log.each do |name, logger|
  if name.include?("filename.log")
    logger.level = "WARN"
  else
    logger.level = "DEBUG"
  end
end
```

Unlike the standard Ruby logger, flushing log contents is more deterministic.
`TeeLogger#flush` flushes not only the Ruby buffers of all loggers, but also
tries to invoke [IO#fsync](http://ruby-doc.org/core-2.2.1/IO.html#method-i-fsync).
In addition, `TeeLogger` lets you set a flush interval indicating after how
many messages logged `TeeLogger#flush` is to be invoked automatically:

```ruby
require 'teelogger'

log = TeeLogger::TeeLogger.new(STDOUT, "filename.log")
log.flush_interval = 1                  # flush every line
log["filename.log"].flush_interval = 2  # flush every other line

log.info "first message"  # flushes STDOUT
log.info "second message" # flushes STDOUT and filename.log
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/teelogger/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## Shameless Plug

Need software testing services? Contact [spriteCloud](http://www.spritecloud.com)

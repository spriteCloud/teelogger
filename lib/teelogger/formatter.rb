#
# TeeLogger
# https://github.com/spriteCloud/teelogger
#
# Copyright (c) 2014-2015 spriteCloud B.V. and other TeeLogger contributors.
# All rights reserved.
#
require 'tai64'

module TeeLogger
  ##
  # Placeholders for the formatter take a single argument, and convert it to
  # a string argument using placeholder specific rules.
  module FormatterPlaceholders
    def severity(severity, _, _, _)
      severity.to_s.upcase
    end

    def short_severity(severity, _, _, _)
      severity.to_s.upcase[0..0]
    end

    def logger_timestamp(_, time, _, _)
      # rubocop:disable Style/FormatString
      time.strftime("%Y-%m-%dT%H:%M:%S.") << "%06d" % time.usec
      # rubocop:enable Style/FormatString
    end

    def iso8601_timestamp(_, time, _, _)
      time.strftime("%Y-%m-%dT%H:%M:%S%z")
    end

    def iso8601_timestamp_utc(_, time, _, _)
      time.dup.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    end

    def tai64n_timestamp(_, time, _, _)
      Tai64::Time.new(time).to_label.to_s
    end

    def logger(_, _, progname, _)
      progname.to_s
    end

    def message(_, _, _, message)
      message.to_s
    end

    def pid(_, _, _, _)
      require "English"
      $PID.to_s
    end

    # rubocop:disable Style/ModuleFunction
    extend self
    # rubocop:enable Style/ModuleFunction
  end # module FormatterPlaceholders

  ##
  # The formatter class accepts a format string, but in a different format from
  # Kernel#sprintf. Instead, placeholders enclosed in {} (but without the Ruby-
  # typical #, so not #{}) will get replaced with the output of the functions
  # defined in FormatterPlaceholders.
  #
  # The class also defines a few example format strings as constants.
  class Formatter
    # Valid placeholder to use in the format string
    PLACEHOLDERS = ::TeeLogger::FormatterPlaceholders.instance_methods

    ##
    # Some format strings defined

    # Format string most similar to the Ruby logger
    FORMAT_LOGGER = "{short_severity}, [{logger_timestamp} \#{pid}] "\
        "{severity} -- {logger}: {message}\n".freeze

    # Default format string
    FORMAT_DEFAULT = "{short_severity}, [{iso8601_timestamp} \#{pid}] "\
        "{logger}: {message}\n".freeze

    # Shorter format string
    FORMAT_SHORT = "{short_severity}, [{iso8601_timestamp}] {message}\n".freeze

    # DJB format using Tai64N labels
    FORMAT_DJB = "{tai64n_timestamp} {severity}: {message}\n".freeze

    ##
    # Implementation
    def initialize(format = FORMAT_DEFAULT)
      @format = format
    end

    def call(*args) # shortern *args; the same pattern as placeholders is used
      # Formatting the message means replacing each placeholder with results
      # from the placeholder function. We're caching results to save some time.
      cache = {}
      message = @format.dup

      PLACEHOLDERS.each do |placeholder|
        value = nil
        begin
          value = cache.fetch(
              placeholder,
              ::TeeLogger::FormatterPlaceholders.send(
                  placeholder.to_sym, *args
              )
          )
          cache[placeholder] = value
        rescue NoMethodError
          raise "Invalid formatter placeholder used in format string: "\
              "#{placeholder}"
        end

        message.gsub!(/{#{placeholder}}/, value)
      end

      return message
    end
  end # class Formatter
end # module TeeLogger

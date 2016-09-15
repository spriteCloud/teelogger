#
# TeeLogger
# https://github.com/spriteCloud/teelogger
#
# Copyright (c) 2014-2015 spriteCloud B.V. and other TeeLogger contributors.
# All rights reserved.
#
require "teelogger/version"
require "teelogger/extensions"
require "teelogger/levels"
require "teelogger/formatter"
require "teelogger/filter"

require "logger"

module TeeLogger
  DEFAULT_FLUSH_INTERVAL = 2000

  ##
  # Logger that writes to multiple outputs. Behaves just like Ruby's Logger,
  # and like a hash of String => Logger.
  #
  # A typical use might be to log to STDOUT, but also to a file:
  #   log = TeeLogger.new(STDOUT, "filename.log")
  #   log.level = Logger::WARN # applies to all outputs
  #   log.level = "INFO"       # convenience shortcut
  #
  # By using the instance as a hash, you can also set individual log levels
  # for individual loggers:
  #   log = TeeLogger.new(STDOUT, "filename.log")
  #   log.each do |name, logger|
  #     if name.include?("filename.log")
  #       logger.level = "WARN"
  #     else
  #       logger.level = "DEBUG"
  #     end
  #   end
  class TeeLogger
    # Extends and includes
    extend  ::TeeLogger::Levels
    include ::TeeLogger::Levels
    include ::TeeLogger::Filter

    ##
    # Define log functions as strings, for internal re-use
    LOG_FUNCTIONS = Logger::Severity.constants.map do |level|
      string_level(level.to_s).downcase
    end

    ##
    # Add a logger to the current loggers.
    def add_logger(arg)
      key = nil
      io = nil
      if arg.is_a? String
        # We have a filename
        key = File.basename(arg)

        # Try to create the logger.
        io = File.new(arg, File::WRONLY | File::APPEND | File::CREAT)
      else
        # We have some other object - let's hope it's an IO object
        key = nil
        case arg
        when STDOUT
          key = 'STDOUT'
        when STDERR
          key = 'STDERR'
        else
          key = arg.to_s
        end

        # Try to create the logger.
        io = arg
      end

      # Initialize logger
      logger = Logger.new(io)
      io.write "Logging to #{key} initialized with level "\
          "#{string_level(@default_level)}.\n"
      logger.level = convert_level(@default_level)

      # Set the logger formatter
      logger.formatter = @formatter

      # Extend logger instances with extra functionality
      logger.extend(::TeeLogger::LoggerExtensions)
      logger.teelogger_io = io
      logger.flush_interval = DEFAULT_FLUSH_INTERVAL

      # Flush the "Logging to..." line
      logger.flush

      if not key.nil? and not logger.nil? and not io.nil?
        @loggers[key] = logger
        @ios[key] = io
      end
    end

    ##
    # Start with any amount of IO objects or filenames; defaults to STDOUT
    def initialize(*args)
      # Handle default
      if args.empty?
        args = [STDOUT]
      end

      # Initialization
      @default_level = Logger::Severity::INFO
      @formatter = ::TeeLogger::Formatter.new
      @loggers = {}
      @ios = {}

      # Load built-in filters
      load_filters(*args)

      # Create logs for all arguments
      args.each do |arg|
        add_logger(arg)
      end
    end

    ##
    # Set log level; override this to also accept strings
    def level=(val)
      # Convert strings to the constant value
      val = convert_level(val)

      # Update the default log level
      @default_level = val

      # Set all loggers' log levels
      @loggers.each do |_, logger|
        logger.level = val
      end
    end

    ##
    # Set the formatter
    def formatter=(formatter)
      # Update the default formatter
      @formatter = formatter

      # Set all loggers' formatters
      @loggers.each do |_, logger|
        logger.formatter = formatter
      end
    end

    ##
    # Log an exception
    def exception(message, ex)
      error("#{message} got #{ex.message}:\n#{ex.backtrace.join("\n")}")
    end

    ##
    # For each log level, define an appropriate logging function
    (["add"] + LOG_FUNCTIONS).each do |meth|
      # Methods corresponding to severity levels will be auto_flushed
      define_method(meth) do |*args, &block|
        x = dispatch(meth, *args, &block)
        dispatch("auto_flush")
        x
      end

      # Query methods for severity levels are defined
      if %w(unknown add).include? meth
        next
      end

      query = "#{meth}?"
      define_method(query) do |*args, &block|
        dispatch(query, *args, &block)
      end
    end

    ##
    # Add flush related functions from LoggerExtensions
    LoggerExtensions.instance_methods(false).each do |method|
      name = method.to_s
      if not name.start_with?("flush")
        next
      end

      define_method(name) do |*args, &block|
        dispatch(name, *args, &block)
      end
    end

    ##
    # Every function this class doesn't have should be mapped to the original
    # logger
    def respond_to_missing?(meth, include_private = false)
      if @loggers.nil? or @loggers.empty?
        raise "No loggers created, can't do anything."
      end

      meth_name = meth.to_s

      # All loggers are the same, so we need to check only one of them.
      @loggers.each do |_, logger|
        if logger.respond_to?(meth_name, include_private)
          return true
        end
        break
      end

      # If this didn't work, we're also emulating a hash
      return @loggers.respond_to?(meth_name, include_private)
    end

    # rubocop:disable Style/MethodMissing
    def method_missing(meth, *args, &block)
      dispatch(meth, *args, &block)
    end
    # rubocop:enable Style/MethodMissing

    private

    def dispatch(meth, *args, &block)
      if @loggers.nil? or @loggers.empty?
        raise "No loggers created, can't do anything."
      end

      # Try dispatching the call, with preprocessing based on whether it
      # is a log function or not.
      meth_name = meth.to_s

      ret = []
      if LOG_FUNCTIONS.include? meth_name
        ret = dispatch_log(meth_name, *args)
      else
        ret = dispatch_other(meth_name, *args, &block)
      end

      # Some double checking on the return value(s).
      if not ret.empty?
        return ret
      end

      # If the method wasn't from the loggers, we'll try to send it to the
      # hash.
      return @loggers.send(meth_name, *args, &block)
    end

    def dispatch_log(meth_name, *args)
      # Filter all arguments
      args = apply_filters(*args)

      # Compose message
      msg = args.map do |arg|
        if arg.is_a? String
          arg
        else
          arg.inspect
        end
      end
      message = msg.join("|")

      # Try to write the message to all loggers.
      ret = []
      @loggers.each do |key, logger|
        if not logger.respond_to? meth_name
          next
        end
        ret << logger.send(meth_name, key) do
          message
        end
      end
      return ret
    end

    def dispatch_other(meth_name, *args, &block)
      ret = []
      @loggers.each do |_, logger|
        if logger.respond_to? meth_name
          ret << logger.send(meth_name, *args, &block)
        end
      end
      return ret
    end
  end
end

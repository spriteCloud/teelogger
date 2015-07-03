#
# TeeLogger
# https://github.com/spriteCloud/teelogger
#
# Copyright (c) 2014-2015 spriteCloud B.V. and other TeeLogger contributors.
# All rights reserved.
#
require "teelogger/version"

require "logger"

module TeeLogger
  DEFAULT_FLUSH_INTERVAL = 2000

  ##
  # Extensions for the ruby logger
  module LoggerExtensions
    attr_accessor :teelogger_io
    attr_accessor :flush_interval

    ##
    # Flush ruby and OS buffers for this logger
    def flush
      if @teelogger_io.nil?
        raise "TeeLogger logger without IO object, can't do anything"
      end

      @teelogger_io.flush
      begin
        @teelogger_io.fsync
      rescue NotImplementedError, Errno::EINVAL
        # pass
      end
    end


    ##
    # This function invokes flush if it's been invoked more often than
    # flush_interval.
    def auto_flush
      if @written.nil?
        @written = 0
      end

      @written += 1

      if @written >= self.flush_interval
        self.flush
        @written = 0
      end
    end
  end # module LoggerExtensions



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
    @default_level
    @loggers
    @ios

    ##
    # Convert a log level to its string name
    def self.string_level(level)
      if level.is_a? String
        return level
      end

      Logger::Severity.constants.each do |const|
        if level == Logger.const_get(const)
          return const
        end
      end

      return nil
    end

    ##
    # Convert a string log level to its constant value
    def self.convert_level(val)
      if val.is_a? String
        begin
          val = Logger.const_get(val.upcase)
        rescue NameError
          raise "Invalid log level '#{val}' specified."
        end
      end

      return val
    end

private
    ##
    # Define log functions as strings, for internal re-use
    LOG_FUNCTIONS = Logger::Severity.constants.map { |level| TeeLogger.string_level(level.to_s).downcase }

public

    ##
    # Add a logger to the current loggers.
    def add_logger(arg)
      key = nil
      logger = nil
      io = nil
      if arg.is_a? String
        # We have a filename
        key = File.basename(arg)

        # Try to create the logger.
        io = File.new(arg, File::WRONLY | File::APPEND | File::CREAT)
        logger = Logger.new(io)

        # Initialize logger
        io.write "Logging to '#{arg}' initialized with level #{TeeLogger.string_level(@default_level)}.\n"
        logger.level = TeeLogger.convert_level(@default_level)
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
        logger = Logger.new(io)

        # Initialize logger
        io.write "Logging to #{key} initialized with level #{TeeLogger.string_level(@default_level)}.\n"
        logger.level = TeeLogger.convert_level(@default_level)
      end

      # Extend logger instances with extra functionality
      logger.extend(LoggerExtensions)
      logger.teelogger_io = io
      logger.flush_interval = DEFAULT_FLUSH_INTERVAL

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
      @loggers = {}
      @ios = {}

      # Create logs for all arguments
      args.each do |arg|
        add_logger(arg)
      end
    end


    ##
    # Set log level; override this to also accept strings
    def level=(val)
      # Convert strings to the constant value
      val = TeeLogger.convert_level(val)

      # Update the default log level
      @default_level = val

      # Set all loggers' log levels
      @loggers.each do |key, logger|
        logger.level = val
      end
    end


    ##
    # Log an exception
    def exception(message, ex)
      error("#{message} got #{ex.message}:\n#{ex.backtrace.join("\n")}")
    end


    ##
    # For each log level, define an appropriate logging function
    ["add"] + LOG_FUNCTIONS.each do |meth|
      # Methods corresponding to severity levels will be auto_flushed
      define_method(meth) { |*args, &block|
        x = dispatch(meth, *args, &block)
        dispatch("auto_flush")
        x
      }

      # Query methods for severity levels are defined
      if not ["unknown", "add"].include? meth
        query = "#{meth}?"
        define_method(query)  { |*args, &block|
          dispatch(query, *args, &block)
        }
      end
    end


    ##
    # Add flush related functions from LoggerExtensions
    LoggerExtensions.instance_methods(false).each do |method|
      name = method.to_s
      if name.start_with?("flush")
        define_method(name) { |*args, &block|
          dispatch(name, *args, &block)
        }
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
      @loggers.each do |key, logger|
        if logger.respond_to?(meth_name, include_private)
          return true
        end
        break
      end

      # If this didn't work, we're also emulating a hash
      return @loggers.respond_to?(meth_name, include_private)
    end

    def method_missing(meth, *args, &block)
      dispatch(meth, *args, &block)
    end

  private


    def dispatch(meth, *args, &block)
      meth_name = meth.to_s

      if @loggers.nil? or @loggers.empty?
        raise "No loggers created, can't do anything."
      end

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
        if logger.respond_to? meth_name
          if LOG_FUNCTIONS.include? meth_name
            ret << logger.send(meth_name, key) do
              message
            end
          else
            ret << logger.send(meth_name, *args, &block)
          end
        end
      end

      # Some double checking on the return value(s).
      if not ret.empty?
        return ret
      end

      # If the method wasn't from the loggers, we'll try to send it to the
      # hash.
      return @loggers.send(meth_name, *args, &block)
    end

  end

end

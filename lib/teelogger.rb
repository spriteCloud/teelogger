#
# TeeLogger
# https://github.com/spriteCloud/teelogger
#
# Copyright (c) 2014 spriteCloud B.V. and other TeeLogger contributors.
# All rights reserved.
#
require "teelogger/version"

require "logger"

module TeeLogger
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
    @default_level = Logger::Severity::INFO
    @loggers


    ##
    # Add a logger to the current loggers.
    def add_logger(arg)
      key = nil
      logger = nil
      if arg.is_a? String
        # We have a filename
        key = File.basename(arg)

        # Try to create the logger.
        file = File.new(arg, File::WRONLY | File::APPEND | File::CREAT)
        logger = Logger.new(file)

        # Initialize logger
        logger.unknown "Logging to '#{arg}' initialized with level #{string_level(@default_level)}."
        logger.level = convert_level(@default_level)
      else
        # We have some other object - let's hope it's an IO object
        key = arg.to_s

        # Try to create the logger.
        logger = Logger.new(arg)

        # Initialize logger
        logger.unknown "Logging to #{key} initialized with level #{string_level(@default_level)}."
        logger.level = convert_level(@default_level)
      end

      if not key.nil? and not logger.nil?
        @loggers[key] = logger
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
      @loggers = {}

      # Create logs for all arguments
      args.each do |arg|
        add_logger(arg)
      end
    end

    ##
    # Convert a log level to its string name
    def string_level(level)
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
    def convert_level(val)
      if val.is_a? String
        begin
          val = Logger.const_get(val)
        rescue NameError
          val = Logger::Severity::WARN
        end
      end

      return val
    end


    ##
    # Set log level; override this to also accept strings
    def level=(val)
      # Convert strings to the constant value
      val = convert_level(val)

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
    # Every function this class doesn't have should be mapped to the original
    # logger
    def respond_to?(meth)
      if @loggers.nil? or @loggers.empty?
        raise "No loggers created, can't do anything."
      end

      meth_name = meth.to_s

      # All loggers are the same, so we need to check only one of them.
      @loggers.each do |key, logger|
        if logger.respond_to? meth_name
          return true
        end
        break
      end

      # If this didn't work, we're also emulating a hash
      return @loggers.respond_to? meth_name
    end

    def method_missing(meth, *args, &block)
      meth_name = meth.to_s

      if @loggers.nil? or @loggers.empty?
        raise "No loggers created, can't do anything."
      end

      # Compose message
      message = ""
      args.each do |arg|
        message += arg.inspect
      end

      # Try to write the message to all loggers.
      ret = []
      @loggers.each do |key, logger|
        if logger.respond_to? meth_name
          if args.length > 0
            ret << logger.send(meth_name, "[#{key}] #{message}", &block)
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

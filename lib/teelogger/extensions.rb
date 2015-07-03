#
# TeeLogger
# https://github.com/spriteCloud/teelogger
#
# Copyright (c) 2014-2015 spriteCloud B.V. and other TeeLogger contributors.
# All rights reserved.
#
module TeeLogger
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
end # module TeeLogger

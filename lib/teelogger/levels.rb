#
# TeeLogger
# https://github.com/spriteCloud/teelogger
#
# Copyright (c) 2014-2015 spriteCloud B.V. and other TeeLogger contributors.
# All rights reserved.
#
module TeeLogger
  module Levels
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
          val = Logger.const_get(val.upcase)
        rescue NameError
          raise "Invalid log level '#{val}' specified."
        end
      end

      return val
    end

  end # module Levels
end # module TeeLogger

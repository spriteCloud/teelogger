#
# TeeLogger
# https://github.com/spriteCloud/teelogger
#
# Copyright (c) 2014,2015 spriteCloud B.V. and other TeeLogger contributors.
# All rights reserved.
#
require 'teelogger/filter'

module TeeLogger
  module Filter
    ##
    # The Assignment filter takes strings of the form <prefix><word>=<value> and
    # obfuscates the value.
    class Assignment < FilterBase
      FILTER_TYPES = [String]
      WINDOW_SIZE  = 1

      def initialize(*args)
        super(*args)

        # We create more complex matches out of the filter words passed.
        @matches = []
        run_data[:words].each do |word|
          @matches << /(-{0,2}#{word} *[=:] *)(.*)/i
        end
      end

      def process(*args)
        # Note that due to the window size of one, args is only an element long.
        args.each do |arg|
          @matches.each do |match|
            # Modify the matching arguments in place
            arg.gsub!(match, '\1[REDACTED]')
          end
        end

        return args
      end
    end # class Assignment
  end # module Filter
end # module TeeLogger

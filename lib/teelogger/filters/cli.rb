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
    # The CLI filter takes sequences of strings of the form ["word", "value"]
    # and obfuscates the value if the word matches.
    class CLI < FilterBase
      FILTER_TYPES = [String]
      WINDOW_SIZE  = 2

      def initialize(*args)
        super(*args)

        # We create more complex matches out of the filter words passed.
        @matches = []
        run_data[:words].each do |word|
          @matches << /(-{0,2}#{word})(.*)/i
        end
      end

      def process(*args)
        @matches.each do |word|
          if word.match(args[0])
            args[1] = '[REDACTED]'
          end
        end
        return args
      end
    end # class CLI
  end # module Filter
end # module TeeLogger

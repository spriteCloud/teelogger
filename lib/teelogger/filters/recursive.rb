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
    # The Recursive filter takes Hashes or Arrays, and recursively applies the
    # other filters to their values.
    class Recursive < FilterBase
      FILTER_TYPES = [Enumerable]
      WINDOW_SIZE  = 1

      def process(*args)
        # For each argument, recurse processing. Note that due to the window
        # size of one, args is only an element long - but let's write this out
        # properly.
        args.each do |arg|
          # Since we're matching enumerabls, the argument must respond to .each
          arg.each do |expanded|
            # The expanded variable can be a single item or a list of items.
            # If expanded is itself an Enumarable, the first item is a key, the remainder
            # values. We need to recursively process the values.
            if expanded.is_a? Enumerable
              # If the key matches any of the filter words, we'll just skip
              # the value entirely.
              key = expanded[0]
              redacted = false
              run_data[:words].each do |word|
                if word.match(key.to_s)
                  arg[key] = '[REDACTED]'
                  redacted = true
                  break
                end
              end

              if not redacted
                ::TeeLogger::Filter.apply_filters_internal(run_data, *expanded[1..-1])
              end
            else
              ::TeeLogger::Filter.apply_filters_internal(run_data, expanded)
            end
          end
        end
      end
    end # class Recursive
  end # module Filter
end # module TeeLogger

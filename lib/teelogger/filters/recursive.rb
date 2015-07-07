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
        processed_args = []

        args.each do |arg|
          # So we have an Enumerable, but we don't know whether it's Array-like
          # or Hash-like. We'll check whether it responds to ".keys", and then
          # treat it as a Hash.
          processed = nil
          if arg.respond_to? :keys
            processed = {}
            # Looks like a Hash, treat it like a Hash
            arg.each do |key, value|

              # If the key is a match, we'll just redact the entire value.
              redacted = false
              run_data[:words].each do |word|
                if word.match(key.to_s)
                   processed[key] = ::TeeLogger::Filter::REDACTED_WORD
                   redacted = true
                   break
                end
              end

              # Otherwise, pass it through
              if not redacted
                processed[key] = run_data[:filters].apply_filters_internal(run_data, value)[0]
              end
            end
          else
            # Treat it like an Array
            processed = run_data[:filters].apply_filters_internal(run_data, *arg)
          end

          processed_args << processed
        end

        return processed_args
      end
    end # class Recursive
  end # module Filter
end # module TeeLogger

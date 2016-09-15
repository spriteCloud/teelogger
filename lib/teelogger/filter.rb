#
# TeeLogger
# https://github.com/spriteCloud/teelogger
#
# Copyright (c) 2014,2015 spriteCloud B.V. and other TeeLogger contributors.
# All rights reserved.
#
require 'require_all'

module TeeLogger
  ##
  # The Filter module collects filtering elated TeeLogger functionality.
  module Filter
    ##
    # The default words to filter. It's up to each individual filter to decide
    # what to do when they encounter a word, but these are the words the filters
    # should process.
    # Note that they can be strings or regular expressions. Regular expressions
    # should by and large not be anchored to the beginning or end of strings.
    DEFAULT_FILTER_WORDS = [
      /password[a-z\-_]*/,
      /salt[a-z\-_]*/,
    ].freeze

    ##
    # Word to use in place of original values
    REDACTED_WORD = "[REDACTED]".freeze

    ##
    # Filter words
    def filter_words
      @filter_words ||= DEFAULT_FILTER_WORDS
      return @filter_words
    end

    def filter_words=(arg)
      # Coerce into array
      arr = []
      arg.each do |item|
        arr << item
      end
      @filter_words = arr
    rescue NameError # also NoMethodError
      raise "Can't set filter words, not iterable: #{arg}"
    end

    ##
    # Load all built-in filters.
    def load_filters(*_)
      require_rel 'filters'
      collected = ::TeeLogger::Filter.constants.collect do |const_sym|
        ::TeeLogger::Filter.const_get(const_sym)
      end
      collected.each do |filter|
        verbose = (ENV['TEELOGGER_VERBOSE'] || 0).to_i
        begin
          register_filter(filter)
          if verbose > 0
            puts "Registered filter #{filter}."
          end
        rescue StandardError => err
          if verbose > 0
            puts "Not registering filter: #{err}"
          end
        end
      end
    end

    ##
    # Returns all registered filters.
    def registered_filters
      # Initialize if it doesn't exist
      @filters ||= {}
      return @filters
    end

    ##
    # Expects a class, registers the class for use by the filter function
    def register_filter(filter)
      # Sanity checks/register filter
      if filter.class != Class
        raise "Ignoring '#{filter}', not a class."
      end

      if not filter < FilterBase
        raise "Class '#{filter}' is not derived from FilterBase."
      end

      begin
        window = filter::WINDOW_SIZE.to_i
        window_filters = registered_filters.fetch(window, {})

        filter::FILTER_TYPES.each do |type|
          type_filters = window_filters.fetch(type, [])
          type_filters.push(filter) unless type_filters.include?(filter)
          window_filters[type] = type_filters
        end

        registered_filters[window] = window_filters
      rescue NameError # also catches NoMethodError
        raise "Class '#{filter}' is missing a FILTER_TYPES Array or a "\
          "WINDOW_SIZE Integer."
      end
    end

    ##
    # Applies all registered filters.
    def apply_filters(*args)
      # Pre-process filter words: we need to have regular expressions everywhere
      words = []
      filter_words.each do |word|
        if word.is_a? Regexp
          words << word
        else
          words << Regexp.new(word.to_s)
        end
      end

      # We instanciate each filter once per application, and store the instnaces
      # in a cache for that duration.
      filter_cache = {}

      # Pass state on to apply_filters_internal
      state = {
        words: words,
        filter_cache: filter_cache,
        filters: self,
      }
      return apply_filters_internal(state, *args)
    end

    ##
    # Implementation of apply_filters that doesn't initialize state, but carries
    # it over. Used internally only.
    def apply_filters_internal(state, *args)
      filtered_args = args

      # Iterate through filters
      registered_filters.each do |window, window_filters|
        # Determine actual window size
        window_size = [window, filtered_args.size].min

        # Process each window so that elements are updated in-place. This
        # means we'll start at index 0 and process up to window_size elements.
        idx = 0
        while (idx + window_size - 1) < filtered_args.size
          # We need to use *one* argument to determine whether the filter
          # type applies. The current strategy is to match the first argument
          # only, and let the filter cast to other types if necessary.
          first_arg = filtered_args[idx]

          window_filters.each do |class_match, type_filters|
            # We process with these type filters if first_arg matches the
            # class_match.
            if not first_arg.is_a? class_match
              next
            end

            # Now process with the given filters.
            type_filters.each do |filter|
              # XXX Do not turn this into a one-liner, or we'll instanciate
              #     filters without using them.
              filter_instance = state[:filter_cache].fetch(filter, nil)
              if filter_instance.nil?
                filter_instance = filter.new(state)
                state[:filter_cache][filter] = filter_instance
              end

              # Single item windows need to be processed a bit differently from
              # multi-item windows.
              tuple = filtered_args[idx..idx + window_size - 1]
              filtered = filter_instance.process(*tuple)

              # Sanity check result
              if filtered.size != tuple.size
                raise "Filter #{filter} added or removed items to the log; "\
                  "don't know how to process!"
              end

              filtered.each_with_index do |item, offset|
                filtered_args[idx + offset] = item
              end
            end # type_filters.each
          end # window_filters.each

          # Advance to the next window
          idx += 1
        end # each window
      end # all registered filters

      return filtered_args
    end

    ##
    # Any filter implementations must derive from this
    class FilterBase
      # Define FILTER_TYPES = [class, class] to declare what types this filter
      # applies to.
      # Define WINDOW_SIZE = int to declare how many parameters the filter
      # processes at a time. It will be a sliding window of arguments.
      # Note that filters may receive fewer arguments if there are less than
      # WINDOW_SIZE in total.

      ##
      # Initialize with filter words
      attr_accessor :run_data

      def initialize(run_data)
        @run_data = run_data
      end

      ##
      # Base filter leaves the argument untouched.
      def process(*args)
        args
      end
    end # class FilterBase
  end # end module Filter
end # end module TeeLogger

require_relative "token.rb"
require_relative "handler/algorithms.rb"
require 'chronic'

module Tickle


  class Handler

    class << self
      # needed to handle the unique situation where a number or ordinal plus optional month or month name is passed that is EQUAL to the start date since Chronic returns that day.
      def handle_same_day_chronic_issue(year, month, day, start)
        Date.new(year.to_i, month.to_i, day.to_i) == start.to_date ?
          Time.local(year, month+1, day) :
          Time.local(year, month, day)
      end


      # runs Chronic.parse with now being set to the specified start date for Tickle parsing
      def chronic_parse_with_start(exp,start)
        Chronic.parse(exp, :now => start)
      end
    end


    def initialize tokens, start
      @tokens = tokens
      @start = start
      @algos = {}.merge GuessAlgorithms
    end


    attr_reader :algos, :tokens, :start


    # The heavy lifting.  Goes through each token groupings to determine what natural language should either by
    # parsed by Chronic or returned.  This methodology makes extension fairly simple, as new token types can be
    # easily added in repeater and then processed by the guess method
    #
    def guess
      return nil if tokens.empty?

      _next = nil
      @algos.each {|name,block|
        _next = block.call tokens, start
        break unless _next.nil?
      }

      # check to see if next is less than now and, if so, set it to next year
      if _next && _next.to_date < start.to_date
        _next = Time.local(
                  _next.year + 1,
                  _next.month,
                  _next.day,
                  _next.hour,
                  _next.min,_next.sec
                )
      end
      # return the next occurrence
      _next.to_time if _next
    end

  end
end

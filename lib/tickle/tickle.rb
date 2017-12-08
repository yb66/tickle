# Copyright (c) 2010 Joshua Lippiner
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Tickle

  require_relative "patterns.rb"
  require 'numerizer'
  require_relative "helpers.rb"
  require_relative "token.rb"
  require_relative "tickled.rb"


  class << self


    # == Configuration options
    #
    # @param [String] text The string Tickle should parse.
    # @param [Hash] specified_options See actual defaults below.
    # @option specified_options [Date,Time,String] :start (Time.now) Start date for future occurrences.  Must be in valid date format.
    # @option specified_options [Date,Time,String] :until (nil) Last date to run occurrences until. Must be in valid date format.
    # @option specified_options [true,false] :next_only (false)
    # @option specified_options [Date,Time] :now (Time.now)
    # @return [Hash]
    #
    #  @example Use by calling Tickle.parse and passing natural language with or without options.
    #    Tickle.parse("every Tuesday")
    #    # => {:next=>2014-08-26 12:00:00 0100, :expression=>"tuesday", :starting=>2014-08-25 16:31:12 0100, :until=>nil}
    #
    def _parse( tickled )

      # check to see if this event starts some other time and reset now
      scan_expression! tickled

      fail(InvalidDateExpression, "the start date (#{@start.to_date}) cannot occur in the past for a future event") if @start && @start.to_date < tickled.now.to_date
      fail(InvalidDateExpression, "the start date (#{@start.to_date}) cannot occur after the end date") if @until && @start.to_date > @until.to_date

      # no need to guess at expression if the start_date is in the future
      best_guess = nil
      if @start.to_date > tickled.now.to_date
        best_guess = @start
      else
        # put the text into a normal format to ease scanning using Chronic
        tickled.filtered = tickled.event.filter
        # split into tokens and then
        # process each original word for implied word
        @tokens = post_tokenize Token.tokenize(tickled.filtered)

        # scan the tokens with each token scanner
        @tokens = Token.scan!(@tokens)

        # remove all tokens without a type
        @tokens.reject! {|token| token.type.nil? }

        # combine number and ordinals into single number
        @tokens = Helpers.combine_multiple_numbers(@tokens)

        # if we can't guess it maybe chronic can
        _guess = guess(@tokens, @start)
        best_guess = _guess || chronic_parse(tickled.event) # TODO fix this call
      end

      fail(InvalidDateExpression, "the next occurrence takes place after the end date specified") if @until && (best_guess.to_date > @until.to_date)
      if !best_guess
        return nil
      elsif !tickled.next_only?
        return {:next => best_guess.to_time, :expression => tickled.event.filter, :starting => @start, :until => @until}
      else
        return best_guess
      end
    end


    # scans the expression for a variety of natural formats, such as 'every thursday starting tomorrow until May 15th
    def scan_expression!(tickled)
      starting,ending,event = nil, nil, nil
      if (md = Patterns::START_EVERY_REGEX.match tickled)
          starting = md[:start].strip
          text = md[:event].strip
          event, ending = process_for_ending(text)
      elsif (md = Patterns::EVERY_START_REGEX.match tickled)
          event = md[:event].strip
          text = md[:start].strip
          starting, ending = process_for_ending(text)
      elsif (md = Patterns::START_ENDING_REGEX.match tickled)
          starting = md[:start].strip
          ending = md[:finish].strip
          event = 'day'
        else
          event, ending = process_for_ending(text)
      end
      tickled.starting  = starting  unless starting.nil?
      tickled.event     = event     unless event.nil?
      tickled.ending    = ending    unless ending.nil?
      # they gave a phrase so if we can't interpret then we need to raise an error
      if tickled.starting && !tickled.starting.to_s.blank?
        @start = chronic_parse(tickled.starting,tickled, :start)
        if @start
          @start.to_time
        else
          fail(InvalidDateExpression,"the starting date expression \"#{tickled.starting}\" could not be interpretted")
        end
      else
        @start = tickled.start && tickled.start.to_time
      end


      if tickled.ending && !tickled.ending.blank?
        @until = chronic_parse(tickled.ending.filter,tickled, :until)
        if @until
          @until.to_time
        else
          fail(InvalidDateExpression,"the ending date expression \"#{tickled.ending}\" could not be interpretted")
        end
      else
        @until =
          if  tickled.starting && !tickled.starting.to_s.blank?
            if tickled.until && !tickled.until.to_s.blank?
              if tickled.until.to_time > @start
                tickled.until.to_time
              end
            end
          end
      end

      @next = nil
      tickled
    end


    # process the remaining expression to see if an until, end, ending is specified
    def process_for_ending(text)
      (md = Patterns::PROCESS_FOR_ENDING.match text) ?
        [ md[:target], md[:ending] ] :
        [text, nil]
    end

    # normalizes each token
    def post_tokenize(tokens)
      _tokens = tokens.map(&:clone)
      _tokens.each do |token|
        token.normalize!
      end
      _tokens
    end


    # Returns an array of types for all tokens
    def token_types
      @tokens.map(&:type)
    end


    # Returns the next available month based on the current day of the month.
    # For example, if get_next_month(15) is called and the start date is the 10th, then it will return the 15th of this month.
    # However, if get_next_month(15) is called and the start date is the 18th, it will return the 15th of next month.
    def get_next_month(number)
      month = number.to_i < @start.day ? (@start.month == 12 ? 1 : @start.month + 1) : @start.month
    end


    def next_appropriate_year(month, day)
      year = (Date.new(@start.year.to_i, month.to_i, day.to_i) == @start.to_date) ? @start.year + 1 : @start.year
      return year
    end


    private


    # slightly modified chronic parser to ensure that the date found is in the future
    # first we check to see if an explicit date was passed and, if so, dont do anything.
    # if, however, a date expression was passed we evaluate and shift forward if needed
    def chronic_parse(exp, tickled, start_or_until)
      exp = Ordinal.new exp
      result =
        if r = Chronic.parse(exp.ordinal_as_number, :now => tickled.now)
          r
        elsif r = (start_or_until && tickled[start_or_until])
          r
        elsif r = (start_or_until == :start && tickled.now)
          r
        end
      if result && result.to_time < Time.now
        result = Time.local(result.year + 1, result.month, result.day, result.hour, result.min, result.sec)
      end
      result
    end

  end



  # This exception is raised if there is an issue with the parsing
  # output from the date expression provided
  class InvalidDateExpression < Exception
  end
end

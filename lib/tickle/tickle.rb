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
    def parse(text, specified_options = {})
      # get options and set defaults if necessary.  Ability to set now is mostly for debugging
      default_options = {:start => Time.now, :next_only => false, :until => nil, :now => Time.now}
      options = default_options.merge specified_options

      # ensure an expression was provided
      fail(ArgumentError, 'date expression is required') unless text

      # ensure the specified options are valid
      specified_options.keys.each do |key|
        fail(ArgumentError, "#{key} is not a valid option key.") unless default_options.keys.include?(key)
      end
      fail(ArgumentError, ':start specified is not a valid datetime.') unless  (is_date(specified_options[:start]) || Chronic.parse(specified_options[:start])) if specified_options[:start]

      # check to see if a valid datetime was passed
      return text if text.is_a?(Date) ||  text.is_a?(Time)

      # check to see if this event starts some other time and reset now
      event = scan_expression(text, options)

      Tickle.dwrite("start: #{@start}, until: #{@until}, now: #{options[:now].to_date}")

      # => ** this is mostly for testing. Bump by 1 day if today (or in the past for testing)
      fail(InvalidDateExpression, "the start date (#{@start.to_date}) cannot occur in the past for a future event") if @start && @start.to_date < Date.today
      fail(InvalidDateExpression, "the start date (#{@start.to_date}) cannot occur after the end date") if @until && @start.to_date > @until.to_date

      # no need to guess at expression if the start_date is in the future
      best_guess = nil
      if @start.to_date > options[:now].to_date
        best_guess = @start
      else
        # put the text into a normal format to ease scanning using Chronic
        event = pre_filter(event)

        # split into tokens
        @tokens = base_tokenize(event)

        # process each original word for implied word
        post_tokenize

        @tokens.each {|x| Tickle.dwrite("raw: #{x.inspect}")}

        # scan the tokens with each token scanner
        @tokens = Repeater.scan(@tokens)

        # remove all tokens without a type
        @tokens.reject! {|token| token.type.nil? }

        # combine number and ordinals into single number
        combine_multiple_numbers

        @tokens.each {|x| Tickle.dwrite("processed: #{x.inspect}")}

        # if we can't guess it maybe chronic can
        best_guess = (guess || chronic_parse(event))
      end

      fail(InvalidDateExpression, "the next occurrence takes place after the end date specified") if @until && best_guess.to_date > @until.to_date

      if !best_guess
        return nil
      elsif options[:next_only] != true
        return {:next => best_guess.to_time, :expression => event.strip, :starting => @start, :until => @until}
      else
        return best_guess
      end
    end


    # scans the expression for a variety of natural formats, such as 'every thursday starting tomorrow until May 15th
    def scan_expression(text, options)
      starting = ending = nil
      case text
        when Patterns::START_EVERY_REGEX
          starting = text.match(Patterns::START_EVERY_REGEX)[:start].strip
          text = text.match(Patterns::START_EVERY_REGEX)[:event].strip
          event, ending = process_for_ending(text)
        when Patterns::EVERY_START_REGEX
          event = text.match(Patterns::EVERY_START_REGEX)[:event].strip
          text = text.match(Patterns::EVERY_START_REGEX)[:start].strip
          starting, ending = process_for_ending(text)
        when Patterns::START_ENDING_REGEX
          starting = text.match(Patterns::START_ENDING_REGEX)[:start].strip
          ending = text.match(Patterns::START_ENDING_REGEX)[:finish].strip
          event = 'day'
        else
          event, ending = process_for_ending(text)
      end

      # they gave a phrase so if we can't interpret then we need to raise an error
      if starting
        @start = chronic_parse(pre_filter(starting),options, :start)
        if @start
          @start.to_time
        else
          fail(InvalidDateExpression,"the starting date expression \"#{starting}\" could not be interpretted")
        end
      else
        @start = options[:start].to_time rescue nil
      end

      if ending
        @until = chronic_parse(pre_filter(ending),options, :until)
        if @until
          @until.to_time
        else
          fail(InvalidDateExpression,"the ending date expression \"#{ending}\" could not be interpretted")
        end
      else
        @until = options[:until].to_time rescue nil
      end

      @next = nil

      return event
    end


    # process the remaining expression to see if an until, end, ending is specified
    def process_for_ending(text)
      if text =~ Patterns::PROCESS_FOR_ENDING
        return text.match(Patterns::PROCESS_FOR_ENDING)[:target], text.match(Patterns::PROCESS_FOR_ENDING)[:ending]
      else
        return text, nil
      end
    end


    # Normalize natural string removing prefix language
    def pre_filter(text)
      return nil unless text

      text.gsub!(/every(\s)?/, '')
      text.gsub!(/each(\s)?/, '')
      text.gsub!(/repeat(s|ing)?(\s)?/, '')
      text.gsub!(/on the(\s)?/, '')
      text.gsub!(/([^\w\d\s])+/, '')
      text.downcase.strip
      text = normalize_us_holidays(text)
    end


    # Split the text on spaces and convert each word into
    # a Token
    def base_tokenize(text)
      text.split(' ').map { |word| Token.new(word) }
    end


    # normalizes each token
    def post_tokenize
      @tokens.each do |token|
        token.word = normalize(token.original)
      end
    end

    # Clean up the specified input text by stripping unwanted characters,
    # converting idioms to their canonical form, converting number words
    # to numbers (three => 3), and converting ordinal words to numeric
    # ordinals (third => 3rd)
    def normalize(text)
      normalized_text = text.to_s.downcase
      normalized_text = Numerizer.numerize(normalized_text)
      normalized_text.gsub!(/['"\.]/, '')
      normalized_text.gsub!(/([\/\-\,\@])/) { ' ' + $1 + ' ' }
      normalized_text
    end

    # Converts natural language US Holidays into a date expression to be
    # parsed.
    def normalize_us_holidays(text)
      normalized_text = text.to_s.downcase
      normalized_text.gsub!(/\bnew\syear'?s?(\s)?(day)?\b/){|md| $1 }
      normalized_text.gsub!(/\bnew\syear'?s?(\s)?(eve)?\b/){|md| $1 }
      normalized_text.gsub!(/\bm(artin\s)?l(uther\s)?k(ing)?(\sday)?\b/){|md| $1 }
      normalized_text.gsub!(/\binauguration(\sday)?\b/){|md| $1 }
      normalized_text.gsub!(/\bpresident'?s?(\sday)?\b/){|md| $1 }
      normalized_text.gsub!(/\bmemorial\sday\b/){|md| $1 }
      normalized_text.gsub!(/\bindepend(e|a)nce\sday\b/){|md| $1 }
      normalized_text.gsub!(/\blabor\sday\b/){|md| $1 }
      normalized_text.gsub!(/\bcolumbus\sday\b/){|md| $1 }
      normalized_text.gsub!(/\bveterans?\sday\b/){|md| $1 }
      normalized_text.gsub!(/\bthanksgiving(\sday)?\b/){|md| $1 }
      normalized_text.gsub!(/\bchristmas\seve\b/){|md| $1 }
      normalized_text.gsub!(/\bchristmas(\sday)?\b/){|md| $1 }
      normalized_text.gsub!(/\bsuper\sbowl(\ssunday)?\b/){|md| $1 }
      normalized_text.gsub!(/\bgroundhog(\sday)?\b/){|md| $1 }
      normalized_text.gsub!(/\bvalentine'?s?(\sday)?\b/){|md| $1 }
      normalized_text.gsub!(/\bs(ain)?t\spatrick'?s?(\sday)?\b/){|md| $1 }
      normalized_text.gsub!(/\bapril\sfool'?s?(\sday)?\b/){|md| $1 }
      normalized_text.gsub!(/\bearth\sday\b/){|md| $1 }
      normalized_text.gsub!(/\barbor\sday\b/){|md| $1 }
      normalized_text.gsub!(/\bcinco\sde\smayo\b/){|md| $1 }
      normalized_text.gsub!(/\bmother'?s?\sday\b/){|md| $1 }
      normalized_text.gsub!(/\bflag\sday\b/){|md| $1 }
      normalized_text.gsub!(/\bfather'?s?\sday\b/){|md| $1 }
      normalized_text.gsub!(/\bhalloween\b/){|md| $1 }
      normalized_text.gsub!(/\belection\sday\b/){|md| $1 }
      normalized_text.gsub!(/\bkwanzaa\b/){|md| $1 }
      normalized_text
    end


    # Turns compound numbers, like 'twenty first' => 21
    def combine_multiple_numbers
      if [:number, :ordinal].all? {|type| token_types.include? type}
        number = token_of_type(:number)
        ordinal = token_of_type(:ordinal)
        combined_original = "#{number.original} #{ordinal.original}"
        combined_word = (number.start.to_s[0] + ordinal.word)
        combined_value = (number.start.to_s[0] + ordinal.start.to_s)
        new_number_token = Token.new(combined_original, combined_word, :ordinal, combined_value, 365)
        @tokens.reject! {|token| (token.type == :number || token.type == :ordinal)}
        @tokens << new_number_token
      end
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


    # Return the number of days in a specified month.
    # If no month is specified, current month is used.
    def days_in_month(month=nil)
      month ||= Date.today.month
      days_in_mon = Date.civil(Date.today.year, month, -1).day
    end


    private


    # slightly modified chronic parser to ensure that the date found is in the future
    # first we check to see if an explicit date was passed and, if so, dont do anything.
    # if, however, a date expression was passed we evaluate and shift forward if needed
    def chronic_parse(exp,options, start_or_until)
      result = 
        Chronic.parse(exp.ordinal_as_number) ||
        (start_or_until && options[start_or_until]) ||
        (start_or_until == :start && options[:now])
      if result && result.to_time < Time.now
        result = Time.local(result.year + 1, result.month, result.day, result.hour, result.min, result.sec)
      end
      result
    end

  end


  class Token
    attr_accessor :original, :word, :type, :interval, :start


    def initialize(original, word=nil, type=nil, start=nil, interval=nil)
      @original = original
      @word = word
      @type = type
      @interval = interval
      @start = start
    end


    # Updates an existing token.  Mostly used by the repeater class.
    def update(type, start=nil, interval=nil)
      @start = start
      @type = type
      @interval = interval
    end
  end


  # This exception is raised if there is an issue with the parsing
  # output from the date expression provided
  class InvalidDateExpression < Exception
  end
end

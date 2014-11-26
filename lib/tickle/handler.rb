module Tickle

  require_relative "helpers.rb"
  require_relative "token.rb"


    # The heavy lifting.  Goes through each token groupings to determine what natural language should either by
    # parsed by Chronic or returned.  This methodology makes extension fairly simple, as new token types can be
    # easily added in repeater and then processed by the guess method
    #
    def self.guess(tokens)
      return nil if tokens.empty?

      guess_unit_types
      guess_weekday unless @next
      guess_month_names unless @next
      guess_number_and_unit unless @next
      guess_ordinal unless @next
      guess_ordinal_and_unit unless @next
      guess_special unless @next

      # check to see if next is less than now and, if so, set it to next year
      @next = Time.local(@next.year + 1, @next.month, @next.day, @next.hour, @next.min, @next.sec) if @next && @next.to_date < @start.to_date

      # return the next occurrence
      return @next.to_time if @next
    end

    def self.guess_unit_types
      @next = @start.bump(:day) if Token.token_types(@tokens).same?([:day])
      @next = @start.bump(:week) if Token.token_types(@tokens).same?([:week])
      @next = @start.bump(:month) if Token.token_types(@tokens).same?([:month])
      @next = @start.bump(:year) if Token.token_types(@tokens).same?([:year])
    end


    def self.guess_weekday
      @next = chronic_parse_with_start("#{Token.token_of_type(:weekday, @tokens).start.to_s}") if Token.token_types(@tokens).same?([:weekday])
    end

    def self.guess_month_names
      @next = chronic_parse_with_start("#{Date::MONTHNAMES[Token.token_of_type(:month_name, @tokens).start]} 1") if Token.token_types(@tokens).same?([:month_name])
    end

    def self.guess_number_and_unit
      @next = @start.bump(:day, Token.token_of_type(:number, @tokens).interval) if Token.token_types(@tokens).same?([:number, :day])
      @next = @start.bump(:week, Token.token_of_type(:number, @tokens).interval) if Token.token_types(@tokens).same?([:number, :week])
      @next = @start.bump(:month, Token.token_of_type(:number, @tokens).interval) if Token.token_types(@tokens).same?([:number, :month])
      @next = @start.bump(:year, Token.token_of_type(:number, @tokens).interval) if Token.token_types(@tokens).same?([:number, :year])
      @next = chronic_parse_with_start("#{Token.token_of_type(:month_name, @tokens).word} #{Token.token_of_type(:number, @tokens).start}") if Token.token_types(@tokens).same?([:number, :month_name])
      @next = chronic_parse_with_start("#{Token.token_of_type(:specific_year, @tokens).word}-#{Token.token_of_type(:month_name, @tokens).start}-#{Token.token_of_type(:number, @tokens).start}") if Token.token_types(@tokens).same?([:number, :month_name, :specific_year])
    end

    def self.guess_ordinal
      @next = handle_same_day_chronic_issue(@start.year, @start.month, Token.token_of_type(:ordinal, @tokens).start) if Token.token_types(@tokens).same?([:ordinal])
    end

    def self.guess_ordinal_and_unit
      @next = handle_same_day_chronic_issue(@start.year, Token.token_of_type(:month_name, @tokens).start, Token.token_of_type(:ordinal, @tokens).start) if Token.token_types(@tokens).same?([:ordinal, :month_name])
      @next = handle_same_day_chronic_issue(@start.year, @start.month, Token.token_of_type(:ordinal, @tokens).start) if Token.token_types(@tokens).same?([:ordinal, :month])
      @next = handle_same_day_chronic_issue(Token.token_of_type(:specific_year, @tokens).word, Token.token_of_type(:month_name, @tokens).start, Token.token_of_type(:ordinal, @tokens).start) if Token.token_types(@tokens).same?([:ordinal, :month_name, :specific_year])

      if Token.token_types(@tokens).same?([:ordinal, :weekday, :month_name])
        @next = chronic_parse_with_start("#{Token.token_of_type(:ordinal, @tokens).word} #{Token.token_of_type(:weekday, @tokens).start.to_s} in #{Date::MONTHNAMES[Token.token_of_type(:month_name, @tokens).start]}")
        @next = handle_same_day_chronic_issue(@start.year, Token.token_of_type(:month_name, @tokens).start, Token.token_of_type(:ordinal, @tokens).start) if @next.to_date == @start.to_date
      end

      if Token.token_types(@tokens).same?([:ordinal, :weekday, :month])
        word        = Token.token_of_type(:ordinal, @tokens).word
        weekday       = Token.token_of_type(:weekday, @tokens).start
        start        = Token.token_of_type(:ordinal, @tokens).start
        next_month  = Helpers.get_next_month(word, @start)
        month       = Date::MONTHNAMES[next_month]
        @next = chronic_parse_with_start("#{word} #{weekday.to_s} in #{month}")
      end
    end

    def self.guess_special
      guess_special_other
      guess_special_beginning unless @next
      guess_special_middle unless @next
      guess_special_end unless @next
    end

    private

    def self.guess_special_other
      @next = @start.bump(:day, 2) if Token.token_types(@tokens).same?([:special, :day]) && Token.token_of_type(:special, @tokens).start == :other
      @next = @start.bump(:week, 2)  if Token.token_types(@tokens).same?([:special, :week]) && Token.token_of_type(:special, @tokens).start == :other
      @next = chronic_parse_with_start('2 months from now') if Token.token_types(@tokens).same?([:special, :month]) && Token.token_of_type(:special, @tokens).start == :other
      @next = chronic_parse_with_start('2 years from now') if Token.token_types(@tokens).same?([:special, :year]) && Token.token_of_type(:special, @tokens).start == :other
    end

    def self.guess_special_beginning
      if Token.token_types(@tokens).same?([:special, :week]) && Token.token_of_type(:special, @tokens).start == :beginning then @next = chronic_parse_with_start('Sunday'); end
      if Token.token_types(@tokens).same?([:special, :month]) && Token.token_of_type(:special, @tokens).start == :beginning then @next = Date.civil(@start.year, @start.month + 1, 1); end
      if Token.token_types(@tokens).same?([:special, :year]) && Token.token_of_type(:special, @tokens).start == :beginning then @next = Date.civil(@start.year+1, 1, 1); end
    end

    def self.guess_special_end
      if Token.token_types(@tokens).same?([:special, :week]) && Token.token_of_type(:special, @tokens).start == :end then @next = chronic_parse_with_start('Saturday'); end
      if Token.token_types(@tokens).same?([:special, :month]) && Token.token_of_type(:special, @tokens).start == :end then @next = Date.civil(@start.year, @start.month, -1); end
      if Token.token_types(@tokens).same?([:special, :year]) && Token.token_of_type(:special, @tokens).start == :end then @next = Date.new(@start.year, 12, 31); end
    end

    def self.guess_special_middle
      if Token.token_types(@tokens).same?([:special, :week]) && Token.token_of_type(:special, @tokens).start == :middle then @next = chronic_parse_with_start('Wednesday'); end
      if Token.token_types(@tokens).same?([:special, :month]) && Token.token_of_type(:special, @tokens).start == :middle then
        @next = (@start.day > 15 ? Date.civil(@start.year, @start.month + 1, 15) : Date.civil(@start.year, @start.month, 15))
      end
      if Token.token_types(@tokens).same?([:special, :year]) && Token.token_of_type(:special, @tokens).start == :middle then
        @next = (@start.day > 15 && @start.month > 6 ? Date.new(@start.year+1, 6, 15) : Date.new(@start.year, 6, 15))
      end
    end

    private

    # runs Chronic.parse with now being set to the specified start date for Tickle parsing
    def self.chronic_parse_with_start(exp)
      Chronic.parse(exp, :now => @start)
    end

    # needed to handle the unique situation where a number or ordinal plus optional month or month name is passed that is EQUAL to the start date since Chronic returns that day.
    def self.handle_same_day_chronic_issue(year, month, day)
      arg_date = 
        Date.new(year.to_i, month.to_i, day.to_i) == @start.to_date ?
        Time.local(year, month+1, day) :
        Time.local(year, month, day)
      arg_date
    end
end

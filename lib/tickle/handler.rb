module Tickle

  require_relative "helpers.rb"
  require_relative "token.rb"


    # The heavy lifting.  Goes through each token groupings to determine what natural language should either by
    # parsed by Chronic or returned.  This methodology makes extension fairly simple, as new token types can be
    # easily added in repeater and then processed by the guess method
    #
    def self.guess(tokens, start)
      return nil if tokens.empty?

      _next = catch(:guessed) {
        %w{guess_unit_types guess_weekday guess_month_names guess_number_and_unit guess_ordinal guess_ordinal_and_unit guess_special}.each do |meth| # TODO pick better enumerator
          send meth, tokens, start
        end
        nil # stop each sending the array to _next
      }

      # check to see if next is less than now and, if so, set it to next year
      if  _next &&
          _next.to_date < start.to_date
            @next = Time.local(_next.year + 1, _next.month, _next.day, _next.hour, _next.min, _next.sec) 
      else
        @next = _next
      end
      # return the next occurrence
      @next.to_time if @next
    end


    def self.guess_unit_types( tokens, start)
      [:day,:week,:month,:year].find {|unit|
        if Token.types(tokens).same?([unit])
          throw :guessed, start.bump(unit)
        end
      }
      nil
    end


    def self.guess_weekday( tokens, start)
      if Token.types(tokens).same? [:weekday]
        throw :guessed, chronic_parse_with_start(
          "#{Token.token_of_type(:weekday,tokens).start.to_s}", start
        )
      end
      nil
    end


    def self.guess_month_names( tokens, start)
      if Token.types(tokens).same? [:month_name]
        throw :guessed, chronic_parse_with_start(
          "#{Date::MONTHNAMES[Token.token_of_type(:month_name,tokens).start]} 1", start
        )
      end
      nil
    end


    def self.guess_number_and_unit( tokens, start)
      _next = 
        [:day,:week,:month,:year].each {|unit|
          if Token.types(tokens).same?([:number, unit])
            throw :guessed, start.bump( unit, Token.token_of_type(:number,tokens).interval )
          end
        }

      if Token.types(tokens).same?([:number, :month_name])
        throw :guessed, chronic_parse_with_start(
          "#{Token.token_of_type(:month_name,tokens, start).word} #{Token.token_of_type(:number,tokens).start}", start
        )
      end
      
      if Token.types(tokens).same?([:number, :month_name, :specific_year])
        throw :guessed, chronic_parse_with_start(
          [
            Token.token_of_type(:specific_year,tokens, start).word,
            Token.token_of_type(:month_name,tokens).start,
            Token.token_of_type(:number,tokens).start
          ].join("_"), start
        )
      end
      nil
    end


    def self.guess_ordinal( tokens, start)
      if Token.types(tokens).same?([:ordinal])
        throw :guessed, handle_same_day_chronic_issue(
          start.year, start.month, Token.token_of_type(:ordinal,tokens).start, start
        )
      end
      nil
    end


    def self.guess_ordinal_and_unit( tokens, start)
      if Token.types(tokens).same?([:ordinal, :month_name])
        throw :guessed, handle_same_day_chronic_issue(
          start.year, Token.token_of_type(:month_name,tokens).start, Token.token_of_type(:ordinal,tokens).start, start
        )
        nil
      end

      if Token.types(tokens).same?([:ordinal, :month])
        throw :guessed, handle_same_day_chronic_issue(
          start.year,
          start.month,
          Token.token_of_type(:ordinal,tokens).start,
          start  
        )
        nil
      end

      if Token.types(tokens).same?([:ordinal, :month_name, :specific_year])
        throw :guessed, handle_same_day_chronic_issue(
          Token.token_of_type(:specific_year,tokens).word, Token.token_of_type(:month_name,tokens).start, Token.token_of_type(:ordinal,tokens).start, start
          )
        nil
      end

      if Token.types(tokens).same?([:ordinal, :weekday, :month_name])
        _next = chronic_parse_with_start(
          "#{Token.token_of_type(:ordinal,tokens).word} #{Token.token_of_type(:weekday,tokens).start.to_s} in #{Date::MONTHNAMES[Token.token_of_type(:month_name,tokens).start]}", start
        )
        if _next.to_date == start.to_date
          throw :guessed, handle_same_day_chronic_issue(start.year, Token.token_of_type(:month_name,tokens).start, Token.token_of_type(:ordinal,tokens).start, start)
        end
        throw :guessed, _next
        nil
      end

      if Token.types(tokens).same?([:ordinal, :weekday, :month])
       _next = chronic_parse_with_start(
          "#{Token.token_of_type(:ordinal,tokens).word} #{Token.token_of_type(:weekday,tokens).start.to_s} in #{Date::MONTHNAMES[get_next_month(Token.token_of_type(:ordinal,tokens).start)]}", start
        )
        _next =
          if _next.to_date == start.to_date
            handle_same_day_chronic_issue(
              start.year, start.month, Token.token_of_type(:ordinal,tokens).start, start
            )
          else
            _next
        end
        throw :guessed, _next
        nil
      end
      nil
    end


    def self.guess_special( tokens, start)
      guess_special_other tokens, start
      guess_special_beginning tokens, start
      guess_special_middle tokens, start
      guess_special_end tokens, start
      nil
    end

    private

    def self.guess_special_other( tokens, start)
      if  Token.types(tokens).same?([:special, :day]) &&
          Token.token_of_type(:special, tokens).start == :other
            throw :guessed, start.bump(:day, 2)
            nil
      end

      if  Token.types(tokens).same?([:special, :week]) &&
          Token.token_of_type(:special, tokens).start == :other
            throw :guessed, start.bump(:week, 2)
            nil
      end

      if  Token.types(tokens).same?([:special, :month]) &&
          Token.token_of_type(:special, tokens).start == :other
            throw :guessed,  chronic_parse_with_start('2 months from now', start)
            nil
      end

      if  Token.types(tokens).same?([:special, :year]) &&
          Token.token_of_type(:special, tokens).start == :other
            throw :guessed, chronic_parse_with_start('2 years from now', start)
            nil
      end
      nil
    end


    def self.guess_special_beginning( tokens, start)
      if  Token.types(tokens).same?([:special, :week]) &&
          Token.token_of_type(:special, tokens).start == :beginning
            throw :guessed, chronic_parse_with_start('Sunday', start)
            nil
      end
      if  Token.types(tokens).same?([:special, :month]) &&
          Token.token_of_type(:special, tokens).start == :beginning
            throw :guessed, Date.civil(start.year, start.month + 1, 1)
            nil
      end
      if  Token.types(tokens).same?([:special, :year]) &&
          Token.token_of_type(:special, tokens).start == :beginning
            throw :guessed, Date.civil(start.year+1, 1, 1)
            nil
      end
      nil
    end

    def self.guess_special_middle( tokens, start)
      if  Token.types(tokens).same?([:special, :week]) &&
          Token.token_of_type(:special, tokens).start == :middle
            throw :guessed, chronic_parse_with_start('Wednesday', start)
            nil
      end

      if  Token.types(tokens).same?([:special, :month]) &&
          Token.token_of_type(:special, tokens).start == :middle
            _next = start.day > 15 ? 
              Date.civil(start.year, start.month + 1, 15) :
              Date.civil(start.year, start.month, 15)
            throw :guessed, _next
            nil
      end

      if  Token.types(tokens).same?([:special, :year]) &&
          Token.token_of_type(:special, tokens).start == :middle
            _next =
              start.day > 15 && start.month > 6 ?
                Date.new(start.year+1, 6, 15) :
                Date.new(start.year, 6, 15)
            throw :guessed, _next
            nil
      end
      nil
    end


    def self.guess_special_end( tokens, start)
      if  Token.types(tokens).same?([:special, :week]) &&
          (Token.token_of_type(:special, tokens).start == :end)
            throw :guessed, chronic_parse_with_start('Saturday', start)
            nil
      end
      if  Token.types(tokens).same?([:special, :month]) &&
          (Token.token_of_type(:special, tokens).start == :end)
            throw :guessed, Date.civil(start.year, start.month, -1)
            nil
      end
      if  Token.types(tokens).same?([:special, :year]) &&
          (Token.token_of_type(:special, tokens).start == :end)
            throw :guessed, Date.new(start.year, 12, 31)
            nil
      end
      nil
    end


    # runs Chronic.parse with now being set to the specified start date for Tickle parsing
    def self.chronic_parse_with_start(exp,start)
      Chronic.parse(exp, :now => start)
    end

    # needed to handle the unique situation where a number or ordinal plus optional month or month name is passed that is EQUAL to the start date since Chronic returns that day.
    def self.handle_same_day_chronic_issue(year, month, day, start)
      arg_date = 
        Date.new(year.to_i, month.to_i, day.to_i) == start.to_date ?
        Time.local(year, month+1, day) :
        Time.local(year, month, day)
      arg_date
    end
end

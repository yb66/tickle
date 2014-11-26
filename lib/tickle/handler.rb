module Tickle

  require_relative "helpers.rb"
  require_relative "token.rb"


    # The heavy lifting.  Goes through each token groupings to determine what natural language should either by
    # parsed by Chronic or returned.  This methodology makes extension fairly simple, as new token types can be
    # easily added in repeater and then processed by the guess method
    #
    def self.guess(tokens)
      return nil if tokens.empty?

      _next = catch(:guessed) {
        %w{guess_unit_types guess_weekday guess_month_names guess_number_and_unit guess_ordinal guess_ordinal_and_unit guess_special}.each do |meth| # TODO pick better enumerator
          send meth, tokens
        end
        nil # stop each sending the array to _next
      }

      # check to see if next is less than now and, if so, set it to next year
      if  _next &&
          _next.to_date < @start.to_date
            @next = Time.local(_next.year + 1, _next.month, _next.day, _next.hour, _next.min, _next.sec) 
      else
        @next = _next
      end
      # return the next occurrence
      @next.to_time if @next
    end


    def self.guess_unit_types( tokens )
      [:day,:week,:month,:year].find {|unit|
        if Token.types(tokens).same?([unit])
          throw :guessed, @start.bump(unit)
        end
      }
      nil
    end


    def self.guess_weekday( tokens )
      if Token.types(tokens).same? [:weekday]
        throw :guessed, chronic_parse_with_start(
          "#{Token.token_of_type(:weekday,tokens).start.to_s}"
        )
      end
      nil
    end


    def self.guess_month_names( tokens )
      if Token.types(tokens).same? [:month_name]
        throw :guessed, chronic_parse_with_start(
          "#{Date::MONTHNAMES[Token.token_of_type(:month_name,tokens).start]} 1"
        )
      end
      nil
    end


    def self.guess_number_and_unit( tokens )
      _next = 
        [:day,:week,:month,:year].each {|unit|
          if Token.types(tokens).same?([:number, unit])
            throw :guessed, @start.bump( unit, Token.token_of_type(:number,tokens).interval )
          end
        }

      if Token.types(tokens).same?([:number, :month_name])
        throw :guessed, chronic_parse_with_start(
          "#{Token.token_of_type(:month_name,tokens).word} #{Token.token_of_type(:number,tokens).start}"
        )
      end
      
      if Token.types(tokens).same?([:number, :month_name, :specific_year])
        throw :guessed, chronic_parse_with_start(
          [
            Token.token_of_type(:specific_year,tokens).word,
            Token.token_of_type(:month_name,tokens).start,
            Token.token_of_type(:number,tokens).start
          ].join("_")
        )
      end
      nil
    end


    def self.guess_ordinal( tokens )
      if Token.types(tokens).same?([:ordinal])
        throw :guessed, handle_same_day_chronic_issue(
          @start.year, @start.month, Token.token_of_type(:ordinal,tokens).start
        )
      end
      nil
    end


    def self.guess_ordinal_and_unit( tokens )
      if Token.types(tokens).same?([:ordinal, :month_name])
        throw :guessed, handle_same_day_chronic_issue(
          @start.year, Token.token_of_type(:month_name,tokens).start, Token.token_of_type(:ordinal,tokens).start
        )
        nil
      end

      if Token.types(tokens).same?([:ordinal, :month])
        throw :guessed, handle_same_day_chronic_issue(@start.year, @start.month, Token.token_of_type(:ordinal,tokens).start)
        nil
      end

      if Token.types(tokens).same?([:ordinal, :month_name, :specific_year])
        throw :guessed, handle_same_day_chronic_issue(
          Token.token_of_type(:specific_year,tokens).word, Token.token_of_type(:month_name,tokens).start, Token.token_of_type(:ordinal,tokens).start
          )
        nil
      end

      if Token.types(tokens).same?([:ordinal, :weekday, :month_name])
        _next = chronic_parse_with_start(
          "#{Token.token_of_type(:ordinal,tokens).word} #{Token.token_of_type(:weekday,tokens).start.to_s} in #{Date::MONTHNAMES[Token.token_of_type(:month_name,tokens).start]}"
        )
        if _next.to_date == @start.to_date
          throw :guessed, handle_same_day_chronic_issue(@start.year, Token.token_of_type(:month_name,tokens).start, Token.token_of_type(:ordinal,tokens).start)
        end
        throw :guessed, _next
        nil
      end

      if Token.types(tokens).same?([:ordinal, :weekday, :month])
       _next = chronic_parse_with_start(
          "#{Token.token_of_type(:ordinal,tokens).word} #{Token.token_of_type(:weekday,tokens).start.to_s} in #{Date::MONTHNAMES[get_next_month(Token.token_of_type(:ordinal,tokens).start)]}"
        )
        _next =
          if _next.to_date == @start.to_date
            handle_same_day_chronic_issue(
              @start.year, @start.month, Token.token_of_type(:ordinal,tokens).start
            )
          else
            _next
        end
        throw :guessed, _next
        nil
      end
      nil
    end


    def self.guess_special( tokens )
      guess_special_other tokens
      guess_special_beginning tokens
      guess_special_middle tokens
      guess_special_end tokens
      nil
    end

    private

    def self.guess_special_other( tokens )
      if  Token.types(tokens).same?([:special, :day]) &&
          Token.token_of_type(:special, tokens).start == :other
            throw :guessed, @start.bump(:day, 2)
            nil
      end

      if  Token.types(tokens).same?([:special, :week]) &&
          Token.token_of_type(:special, tokens).start == :other
            throw :guessed, @start.bump(:week, 2)
            nil
      end

      if  Token.types(tokens).same?([:special, :month]) &&
          Token.token_of_type(:special, tokens).start == :other
            throw :guessed,  chronic_parse_with_start('2 months from now')
            nil
      end

      if  Token.types(tokens).same?([:special, :year]) &&
          Token.token_of_type(:special, tokens).start == :other
            throw :guessed, chronic_parse_with_start('2 years from now')
            nil
      end
      nil
    end


    def self.guess_special_beginning( tokens )
      if  Token.types(tokens).same?([:special, :week]) &&
          Token.token_of_type(:special, tokens).start == :beginning
            throw :guessed, chronic_parse_with_start('Sunday')
            nil
      end
      if  Token.types(tokens).same?([:special, :month]) &&
          Token.token_of_type(:special, tokens).start == :beginning
            throw :guessed, Date.civil(@start.year, @start.month + 1, 1)
            nil
      end
      if  Token.types(tokens).same?([:special, :year]) &&
          Token.token_of_type(:special, tokens).start == :beginning
            throw :guessed, Date.civil(@start.year+1, 1, 1)
            nil
      end
      nil
    end

    def self.guess_special_middle( tokens )
      if  Token.types(tokens).same?([:special, :week]) &&
          Token.token_of_type(:special, tokens).start == :middle
            throw :guessed, chronic_parse_with_start('Wednesday')
            nil
      end

      if  Token.types(tokens).same?([:special, :month]) &&
          Token.token_of_type(:special, tokens).start == :middle
            _next = @start.day > 15 ? 
              Date.civil(@start.year, @start.month + 1, 15) :
              Date.civil(@start.year, @start.month, 15)
            throw :guessed, _next
            nil
      end

      if  Token.types(tokens).same?([:special, :year]) &&
          Token.token_of_type(:special, tokens).start == :middle
            _next =
              @start.day > 15 && @start.month > 6 ?
                Date.new(@start.year+1, 6, 15) :
                Date.new(@start.year, 6, 15)
            throw :guessed, _next
            nil
      end
      nil
    end


    def self.guess_special_end( tokens )
      if  Token.types(tokens).same?([:special, :week]) &&
          (Token.token_of_type(:special, tokens).start == :end)
            throw :guessed, chronic_parse_with_start('Saturday')
            nil
      end
      if  Token.types(tokens).same?([:special, :month]) &&
          (Token.token_of_type(:special, tokens).start == :end)
            throw :guessed, Date.civil(@start.year, @start.month, -1)
            nil
      end
      if  Token.types(tokens).same?([:special, :year]) &&
          (Token.token_of_type(:special, tokens).start == :end)
            throw :guessed, Date.new(@start.year, 12, 31)
            nil
      end
      nil
    end


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

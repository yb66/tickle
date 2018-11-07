module Tickle
  class Handler
    GuessAlgorithms = {
      guess_unit_types: ->( tokens, start) {
        [:sec,:day,:week,:month,:year].each {|unit|
          if Token.types(tokens).same?([unit])
            return start.bump(unit)
          end
        }
        nil
      },


      guess_weekday: ->( tokens, start) {
        if Token.types(tokens).same? [:weekday]
          chronic_parse_with_start(
            "#{Token.token_of_type(:weekday,tokens).start.to_s}", start
          )
        end
      },


      guess_month_names: ->( tokens, start) {
        if Token.types(tokens).same? [:month_name]
          chronic_parse_with_start(
            "#{Date::MONTHNAMES[Token.token_of_type(:month_name,tokens).start]} 1", start
          )
        end
      },


      guess_number_and_unit: ->( tokens, start) {
        [:sec,:day,:week,:month,:year].each {|unit|
          if Token.types(tokens).same?([:number, unit])
            return start.bump( unit, Token.token_of_type(:number,tokens).interval )
          end
        }

        if Token.types(tokens).same?([:number, :month_name])
          return chronic_parse_with_start(
            "#{Token.token_of_type(:month_name,tokens, start).word} #{Token.token_of_type(:number,tokens).start}", start
          )
        end
      
        if Token.types(tokens).same?([:number, :month_name, :specific_year])
          return chronic_parse_with_start(
            [
              Token.token_of_type(:specific_year,tokens, start).word,
              Token.token_of_type(:month_name,tokens).start,
              Token.token_of_type(:number,tokens).start
            ].join("_"), start
          )
        end
      },


      guess_ordinal: ->( tokens, start) {
        if Token.types(tokens).same?([:ordinal])
          return handle_same_day_chronic_issue(
            start.year, start.month, Token.token_of_type(:ordinal,tokens).start, start
          )
        end
      },


      guess_ordinal_and_unit: ->( tokens, start) {
        case Token.types(tokens) # << this is sorted!
          when [:month_name, :ordinal]
            handle_same_day_chronic_issue(
              start.year, Token.token_of_type(:month_name,tokens).start, Token.token_of_type(:ordinal,tokens).start, start
            )

          when [:month,:ordinal]
            handle_same_day_chronic_issue(
              start.year,
              start.month,
              Token.token_of_type(:ordinal,tokens).start,
              start  
            )

          when [:month_name, :ordinal, :specific_year]
            handle_same_day_chronic_issue(
              Token.token_of_type(:specific_year,tokens).word, Token.token_of_type(:month_name,tokens).start, Token.token_of_type(:ordinal,tokens).start, start
            )

          when [:month_name, :ordinal, :weekday]
            _next = chronic_parse_with_start(
              "#{Token.token_of_type(:ordinal,tokens).word} #{Token.token_of_type(:weekday,tokens).start.to_s} in #{Date::MONTHNAMES[Token.token_of_type(:month_name,tokens).start]}", start
            )
            _next.to_date == start.to_date ?
              handle_same_day_chronic_issue(
                start.year,
                Token.token_of_type(:month_name,tokens).start,
                Token.token_of_type(:ordinal,tokens).start,
                start) :
              _next

          when [:month, :ordinal, :weekday]
           _next = chronic_parse_with_start( tokens, start )

            if _next.to_date == start.to_date
              _next = handle_same_day_chronic_issue(
                start.year,
                start.month,
                Token.token_of_type(:ordinal,tokens).start,
                start
              )
            end
            _next
        end
      },


      guess_special_other: ->( tokens, start) {
        if  Token.types(tokens).same?([:special, :day]) &&
            Token.token_of_type(:special, tokens).start == :other
              return start.bump(:day, 2)
        end

        if  Token.types(tokens).same?([:special, :week]) &&
            Token.token_of_type(:special, tokens).start == :other
              return start.bump(:week, 2)
        end

        if  Token.types(tokens).same?([:special, :month]) &&
            Token.token_of_type(:special, tokens).start == :other
              return chronic_parse_with_start('2 months from now', start)
        end

        if  Token.types(tokens).same?([:special, :year]) &&
            Token.token_of_type(:special, tokens).start == :other
              return chronic_parse_with_start('2 years from now', start)
        end
      },


      guess_special_beginning: ->( tokens, start) {
        if  Token.types(tokens).same?([:special, :week]) &&
            Token.token_of_type(:special, tokens).start == :beginning
              return chronic_parse_with_start('Sunday', start)
        end
        if  Token.types(tokens).same?([:special, :month]) &&
            Token.token_of_type(:special, tokens).start == :beginning
              return Date.civil(start.year, start.month + 1, 1)
        end
        if  Token.types(tokens).same?([:special, :year]) &&
            Token.token_of_type(:special, tokens).start == :beginning
              return Date.civil(start.year+1, 1, 1)
        end
      },


      guess_special_middle: ->( tokens, start) {
        if  Token.types(tokens).same?([:special, :week]) &&
            Token.token_of_type(:special, tokens).start == :middle
              return chronic_parse_with_start('Wednesday', start)
        end

        if  Token.types(tokens).same?([:special, :month]) &&
            Token.token_of_type(:special, tokens).start == :middle
            return start.day > 15 ? 
              Date.civil(start.year, start.month + 1, 15) :
              Date.civil(start.year, start.month, 15)
        end

        if  Token.types(tokens).same?([:special, :year]) &&
            Token.token_of_type(:special, tokens).start == :middle
             return start.day > 15 && start.month > 6 ?
              Date.new(start.year+1, 6, 15) :
              Date.new(start.year, 6, 15)
        end
      },


      guess_special_end: ->( tokens, start) {
        if  Token.types(tokens).same?([:special, :week]) &&
            (Token.token_of_type(:special, tokens).start == :end)
              return chronic_parse_with_start('Saturday', start)
        end
        if  Token.types(tokens).same?([:special, :month]) &&
            (Token.token_of_type(:special, tokens).start == :end)
              return Date.civil(start.year, start.month, -1)
        end
        if  Token.types(tokens).same?([:special, :year]) &&
            (Token.token_of_type(:special, tokens).start == :end)
            return Date.new(start.year, 12, 31)
        end
      },
    }
  end
end
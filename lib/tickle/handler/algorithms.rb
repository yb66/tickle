module Tickle
  class Handler


    GuessAlgorithms = {
      guess_unit_types: ->( tokens, start) {
        [:sec,:day,:week,:month,:year].each {|unit|
          if tokens.types.same?([unit])
            return start.bump(unit)
          end
        }
        nil
      },


      guess_weekday: ->( tokens, start) {
        if tokens.types.same? [:weekday]
          chronic_parse_with_start(
            "#{tokens.token_of_type(:weekday).start.to_s}", start
          )
        end
      },


      guess_month_names: ->( tokens, start) {
        if tokens.types.same? [:month_name]
          chronic_parse_with_start(
            "#{Date::MONTHNAMES[tokens.token_of_type(:month_name).start]} 1", start
          )
        end
      },


      guess_number_and_unit: ->( tokens, start) {
        [:sec,:day,:week,:month,:year].each {|unit|
          if tokens.types.same?([:number, unit])
            return start.bump( unit, tokens.token_of_type(:number).interval )
          end
        }

        if tokens.types.same?([:number, :month_name])
          return chronic_parse_with_start(
            "#{tokens.token_of_type(:month_name).word} #{tokens.token_of_type(:number).start}", start
          )
        end
      
        if tokens.types.same?([:number, :month_name, :specific_year])
          return chronic_parse_with_start(
            [
              tokens.token_of_type(:specific_year).word,
              tokens.token_of_type(:month_name).start,
              tokens.token_of_type(:number).start
            ].join("_"), start
          )
        end
      },


      guess_ordinal: ->( tokens, start) {
        if tokens.types.same?([:ordinal])
          return handle_same_day_chronic_issue(
            start.year, start.month, tokens.token_of_type(:ordinal).start, start
          )
        end
      },


      guess_ordinal_and_unit: ->( tokens, start) {
        case tokens.types.sort
          when [:month_name, :ordinal]
            handle_same_day_chronic_issue(
              start.year, tokens.token_of_type(:month_name).start, tokens.token_of_type(:ordinal).start, start
            )

          when [:month,:ordinal]
            handle_same_day_chronic_issue(
              start.year,
              start.month,
              tokens.token_of_type(:ordinal).start,
              start  
            )

          when [:month_name, :ordinal, :specific_year]
            handle_same_day_chronic_issue(
              tokens.token_of_type(:specific_year).word, tokens.token_of_type(:month_name).start, tokens.token_of_type(:ordinal).start, start
            )

          when [:month_name, :ordinal, :weekday]
            _next = chronic_parse_with_start(
              "#{tokens.token_of_type(:ordinal).word} #{tokens.token_of_type(:weekday).start.to_s} in #{Date::MONTHNAMES[tokens.token_of_type(:month_name).start]}", start
            )
            _next.to_date == start.to_date ?
              handle_same_day_chronic_issue(
                start.year,
                tokens.token_of_type(:month_name).start,
                tokens.token_of_type(:ordinal).start,
                start) :
              _next

          when [:month, :ordinal, :weekday]
           _next = chronic_parse_with_start( tokens, start )

            if _next.to_date == start.to_date
              _next = handle_same_day_chronic_issue(
                start.year,
                start.month,
                tokens.token_of_type(:ordinal).start,
                start
              )
            end
            _next
        end
      },


      guess_special_other: ->( tokens, start) {
        if  tokens.types.same?([:special, :day]) &&
            tokens.token_of_type(:special).start == :other
              return start.bump(:day, 2)
        end

        if  tokens.types.same?([:special, :week]) &&
            tokens.token_of_type(:special).start == :other
              return start.bump(:week, 2)
        end

        if  tokens.types.same?([:special, :month]) &&
            tokens.token_of_type(:special).start == :other
              return chronic_parse_with_start('2 months from now', start)
        end

        if  tokens.types.same?([:special, :year]) &&
            tokens.token_of_type(:special).start == :other
              return chronic_parse_with_start('2 years from now', start)
        end
      },


      guess_special_beginning: ->( tokens, start) {
        if  tokens.types.same?([:special, :week]) &&
            tokens.token_of_type(:special).start == :beginning
              return chronic_parse_with_start('Sunday', start)
        end
        if  tokens.types.same?([:special, :month]) &&
            tokens.token_of_type(:special).start == :beginning
              return Date.civil(start.year, start.month + 1, 1)
        end
        if  tokens.types.same?([:special, :year]) &&
            tokens.token_of_type(:special).start == :beginning
              return Date.civil(start.year+1, 1, 1)
        end
      },


      guess_special_middle: ->( tokens, start) {
        if  tokens.types.same?([:special, :week]) &&
            tokens.token_of_type(:special).start == :middle
              return chronic_parse_with_start('Wednesday', start)
        end

        if  tokens.types.same?([:special, :month]) &&
            tokens.token_of_type(:special).start == :middle
            return start.day > 15 ? 
              Date.civil(start.year, start.month + 1, 15) :
              Date.civil(start.year, start.month, 15)
        end

        if  tokens.types.same?([:special, :year]) &&
            tokens.token_of_type(:special).start == :middle
             return start.day > 15 && start.month > 6 ?
              Date.new(start.year+1, 6, 15) :
              Date.new(start.year, 6, 15)
        end
      },


      guess_special_end: ->( tokens, start) {
        if  tokens.types.same?([:special, :week]) &&
            (tokens.token_of_type(:special).start == :end)
              return chronic_parse_with_start('Saturday', start)
        end
        if  tokens.types.same?([:special, :month]) &&
            (tokens.token_of_type(:special).start == :end)
              return Date.civil(start.year, start.month, -1)
        end
        if  tokens.types.same?([:special, :year]) &&
            (tokens.token_of_type(:special).start == :end)
            return Date.new(start.year, 12, 31)
        end
      },
    }
  end
end
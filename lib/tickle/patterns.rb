module Tickle

  # A place to keep all the regular expressions.
  module Patterns
  
    PLURAL_OR_PRESENT_PARTICIPLE = /
        s
          |
        ing
    /x

    ON_THE = /
      \bon\b
      (?:
        \s+
        the
      )?
    /x

    END_OR_UNTIL  = /
      (?:
        \bend
        (?: #{PLURAL_OR_PRESENT_PARTICIPLE} )?
        (?:
          \s+
          #{ON_THE}
        )?
      )
        |
      (:?
        until
        (?:
          \s+
          \bthe\b
        )?
      )
    /x

    SET_IDENTIFIER = /
      every
        |
      each
        |
      #{ON_THE}
        |
      repeat
    /x

    START = /
      start
      (?: #{PLURAL_OR_PRESENT_PARTICIPLE} )?
    /x

    START_EVERY_REGEX = /^
      (?:
        #{START}
      )
      \s+
      (?<start>.*?)
      \s+
      (?: #{SET_IDENTIFIER} )
      \s+
      (?<event>.*)
    /ix


    EVERY_START_REGEX = /^
      (?: #{SET_IDENTIFIER} )
      \s+
      (?<event>.*)
      (?:
        \s+
        #{START}
        (?:
          \s+
          #{ON_THE}
        )?
      )
      \s+
      (?<start>.*)
    /ix

    START_ENDING_REGEX = /^
      #{START}
      \s+
      (?<start>.*)
      (?:
        \s+
        #{END_OR_UNTIL}
      )
      \s+
      (?<finish>.*)
    /ix

    PROCESS_FOR_ENDING = /^
      (?<target>.*)
      \s+
      (?: #{END_OR_UNTIL})
      \s+
      (?<ending>.*)
    /ix

  end
end
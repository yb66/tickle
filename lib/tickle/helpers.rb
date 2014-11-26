module Tickle

  require_relative "token.rb"

  # static methods that are used across classes.
  module Helpers

    # Returns the next available month based on the current day of the month.
    # For example, if get_next_month(15) is called and the start date is the 10th, then it will return the 15th of this month.
    # However, if get_next_month(15) is called and the start date is the 18th, it will return the 15th of next month.
    def self.get_next_month(number,start=nil)
      start ||= @start || Time.now
      month =
        if number.to_i < start.day
          start.month == 12 ?
            1 :
            start.month + 1
        else
          start.month
        end
    end



    # Return the number of days in a specified month.
    # If no month is specified, current month is used.
    def self.days_in_month(month=nil)
      month ||= Date.today.month
      days_in_mon = Date.civil(Date.today.year, month, -1).day
    end


    # Turns compound numbers, like 'twenty first' => 21
    def self.combine_multiple_numbers(tokens)
      if  Token.types(tokens).include?(:number) &&
          Token.types(tokens).include?(:ordinal) 
            number = Token.token_of_type(:number, tokens)
            ordinal = Token.token_of_type(:ordinal, tokens)
            combined_original = "#{number.original} #{ordinal.original}"
            combined_word = (number.start.to_s[0] + ordinal.word)
            combined_value = (number.start.to_s[0] + ordinal.start.to_s)
            new_number_token = Token.new(combined_original, word: combined_word, type: :ordinal, start: combined_value, interval: 365)
            tokens.reject! {|token| (token.type == :number || token.type == :ordinal)}
            tokens << new_number_token
      end
      tokens
    end


  end # Helpers
end
module Tickle
  class Repeater
    require_relative "token.rb"
    #
    def self.scan(tokens)
      # for each token
      tokens.each do |token|
        token = self.scan_for_numbers(token)
        token = self.scan_for_ordinal_names(token) unless token.type
        token = self.scan_for_ordinals(token) unless token.type
        token = self.scan_for_month_names(token) unless token.type
        token = self.scan_for_day_names(token) unless token.type
        token = self.scan_for_year_name(token) unless token.type
        token = self.scan_for_special_text(token) unless token.type
        token = self.scan_for_units(token) unless token.type
      end
      tokens
    end

    def self.scan_for_numbers(token)
      regex = /\b(\d\d?)\b/
      token.update!(type: :number, start: token.word.gsub(regex,'\1').to_i, interval: token.word.gsub(regex,'\1').to_i) if token.word =~ regex
      token
    end

    def self.scan_for_ordinal_names(token)
      scanner = {/first/ => '1st',
        /second/ => '2nd',
        /third/ => '3rd',
        /fourth/ => '4th',
        /fifth/ => '5th',
        /sixth/ => '6th',
        /seventh/ => '7th',
        /eighth/ => '8th',
        /ninth/ => '9th',
        /tenth/ => '10th',
        /eleventh/ => '11th',
        /twelfth/ => '12th',
        /thirteenth/ => '13th',
        /fourteenth/ => '14th',
        /fifteenth/ => '15th',
        /sixteenth/ => '16th',
        /seventeenth/ => '17th',
        /eighteenth/ => '18th',
        /nineteenth/ => '19th',
        /twentieth/ => '20th',
        /thirtieth/ => '30th',
      }
      scanner.keys.each do |scanner_item|
        if scanner_item =~ token.original
          token.word = scanner[scanner_item]
          token.update!(type: :ordinal, start: scanner[scanner_item].ordinal_as_number, interval: Helpers.days_in_month(Helpers.get_next_month(scanner[scanner_item].ordinal_as_number)))
        end
      end
      token
    end

    def self.scan_for_ordinals(token)
      regex = /\b(\d*)(st|nd|rd|th)\b/
      if token.original =~ regex
        token.word = token.original
        token.update!(type: :ordinal, start: token.word.ordinal_as_number, interval: Helpers.days_in_month(Helpers.get_next_month(token.word)))
      end
      token
    end

    def self.scan_for_month_names(token)
      scanner = {/^jan\.?(uary)?$/ => 1,
        /^feb\.?(ruary)?$/ => 2,
        /^mar\.?(ch)?$/ => 3,
        /^apr\.?(il)?$/ => 4,
        /^may$/ => 5,
        /^jun\.?e?$/ => 6,
        /^jul\.?y?$/ => 7,
        /^aug\.?(ust)?$/ => 8,
        /^sep\.?(t\.?|tember)?$/ => 9,
        /^oct\.?(ober)?$/ => 10,
        /^nov\.?(ember)?$/ => 11,
      /^dec\.?(ember)?$/ => 12}
      scanner.keys.each do |scanner_item|
        token.update!(type: :month_name, start: scanner[scanner_item], interval: 30) if scanner_item =~ token.word
      end
      token
    end

    def self.scan_for_day_names(token)
      scanner = {/^m[ou]n(day)?$/ => :monday,
        /^t(ue|eu|oo|u|)s(day)?$/ => :tuesday,
        /^tue$/ => :tuesday,
        /^we(dnes|nds|nns)day$/ => :wednesday,
        /^wed$/ => :wednesday,
        /^th(urs|ers)day$/ => :thursday,
        /^thu$/ => :thursday,
        /^fr[iy](day)?$/ => :friday,
        /^sat(t?[ue]rday)?$/ => :saturday,
      /^su[nm](day)?$/ => :sunday}
      scanner.keys.each do |scanner_item|
        token.update!(type: :weekday, start: scanner[scanner_item], interval: 7) if scanner_item =~ token.word
      end
      token
    end

    def self.scan_for_year_name(token)
      regex = /\b\d{4}\b/
      token.update!(type: :specific_year, start: token.original.gsub(regex,'\1'), interval: 365) if token.original =~ regex
      token
    end

    def self.scan_for_special_text(token)
      scanner = {/^other$/ => :other,
        /^begin(ing|ning)?$/ => :beginning,
        /^start$/ => :beginning,
        /^end$/ => :end,
      /^mid(d)?le$/ => :middle}
      scanner.keys.each do |scanner_item|
        token.update!(
          type: :special,
          start: scanner[scanner_item], interval: 7
        ) if scanner_item =~ token.word
      end
      token
    end

    def self.scan_for_units(token)
      scanner = {/^year(ly)?s?$/ => {:type => :year, :interval => 365, :start => :today},
        /^month(ly)?s?$/ => {:type => :month, :interval => 30, :start => :today},
        /^fortnights?$/ => {:type => :fortnight, :interval => 365, :start => :today},
        /^week(ly)?s?$/ => {:type => :week, :interval => 7, :start => :today},
        /^weekends?$/ => {:type => :weekend, :interval => 7, :start => :saturday},
        /^days?$/ => {:type => :day, :interval => 0, :start => :today},
      /^daily?$/ => {:type => :day, :interval => 0, :start => :today}}
      scanner.keys.each do |scanner_item|
        if scanner_item =~ token.word
          token.update!(
            type: scanner[scanner_item][:type],
            start: scanner[scanner_item][:start],
            interval: scanner[scanner_item][:interval]
          ) if scanner_item =~ token.word
        end
      end
      token
    end


  end
end
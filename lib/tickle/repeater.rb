module Tickle
  require_relative "../ext/string.rb"
  class Repeater
    require_relative "token.rb"

    attr_reader :tokens

    def initialize( tokens )
      @tokens = tokens.map(&:clone)
    end

    
    SCANNING_METHODS  = [
      :scan_for_numbers,
      :scan_for_ordinal_names,
      :scan_for_ordinals,
      :scan_for_month_names,
      :scan_for_day_names,
      :scan_for_year_name,
      :scan_for_special_text,
      :scan_for_units,
    ]


    #
    def scan!
      # for each token
      @tokens.each do |token|
        new_details = catch(:token_found) {
          SCANNING_METHODS.each{|meth|
            send meth, token
          }
          nil # if nothing matched, set to nil
        }
        token.update! new_details if new_details
      end
      self
    end


    def detection(token, scanner, &block )
      scanner = [scanner] unless scanner.respond_to? :keys
      scanner.each do |key,value|
        if (md = key.match token.downcase) or (md = key.match token.word)
          throw :token_found, block.call(md,key,value)
        end
      end
      nil # if it reaches here nothing was found so return nil
    end


    SCAN_FOR_NUMBERS = /
      \b
      (?<number>\d\d?)
      \b
    /x

    def scan_for_numbers(token)
      detection token, SCAN_FOR_NUMBERS do |md,key,value|
        n = md[:number].to_i
        {type: :number, start: n, interval: n }
      end
    end


    SCAN_FOR_ORDINAL_NAMES = {
      /first/       => Ordinal.new( '1st' ),
      /second\b/    => Ordinal.new( '2nd' ),
      /third/       => Ordinal.new( '3rd' ),
      /fourth/      => Ordinal.new( '4th' ),
      /fifth/       => Ordinal.new( '5th' ),
      /sixth/       => Ordinal.new( '6th' ),
      /seventh/     => Ordinal.new( '7th' ),
      /eighth/      => Ordinal.new( '8th' ),
      /ninth/       => Ordinal.new( '9th' ),
      /tenth/       => Ordinal.new( '10th' ),
      /eleventh/    => Ordinal.new( '11th' ),
      /twelfth/     => Ordinal.new( '12th' ),
      /thirteenth/  => Ordinal.new( '13th' ),
      /fourteenth/  => Ordinal.new( '14th' ),
      /fifteenth/   => Ordinal.new( '15th' ),
      /sixteenth/   => Ordinal.new( '16th' ),
      /seventeenth/ => Ordinal.new( '17th' ),
      /eighteenth/  => Ordinal.new( '18th' ),
      /nineteenth/  => Ordinal.new( '19th' ),
      /twentieth/   => Ordinal.new( '20th' ),
      /thirtieth/   => Ordinal.new( '30th' ),
    }


    def scan_for_ordinal_names(token)
      detection token, SCAN_FOR_ORDINAL_NAMES do |md,key,value|
          { :type     =>  :ordinal,
            :start    =>  value.ordinal_as_number,
            :interval =>  Tickle::Helpers.days_in_month( Tickle::Helpers.get_next_month( value.ordinal_as_number )),
          }
      end
    end


    SCAN_FOR_ORDINALS = /
      \b
      (?<number>\d+)
      (?:
        st
          |
        nd
          |
        rd
          |th
        )
      \b
    /x

    def scan_for_ordinals(token)
      detection token, SCAN_FOR_ORDINALS do |md,key,value|
        number = Ordinal.new(md[:number])
        { :type     =>  :ordinal,
          :start    =>  number.ordinal_as_number,
          :interval =>  Tickle::Helpers.days_in_month(Tickle::Helpers.get_next_month number )
        }
      end
    end


    def scan_for_month_names(token)
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
      detection token, scanner do |md,key,value|
        {
          :type     =>  :month_name,
          :start    =>  value,
          :interval =>  30,
        }
      end
    end


    def scan_for_day_names(token)
      scanner = {
        /^m[ou]n(day)?$/          => :monday,
        /^t(ue|eu|oo|u|)s(day)?$/ => :tuesday,
        /^tue$/                   => :tuesday,
        /^we(dnes|nds|nns)day$/   => :wednesday,
        /^wed$/                   => :wednesday,
        /^th(urs|ers)day$/        => :thursday,
        /^thu$/                   => :thursday,
        /^fr[iy](day)?$/          => :friday,
        /^sat(t?[ue]rday)?$/      => :saturday,
        /^su[nm](day)?$/          => :sunday
      }
      detection token, scanner do |md,key,value|
        {
          :type     => :weekday,
          :start    =>  value,
          :interval =>  7,
        }
      end
    end


    def scan_for_year_name(token)
      detection token, /\b(?<year>\d{4})\b/ do |md,key,value|
        {
          :type     =>  :specific_year,
          :start    =>  md[:year],
          :interval =>  365,
        }
      end
    end


    def scan_for_special_text(token)
      scanner = {
        /^other$/             => :other,
        /^begin(ing|ning)?$/  => :beginning,
        /^start$/             => :beginning,
        /^end$/               => :end,
        /^mid(d)?le$/         => :middle
      }
      detection token, scanner do |md,key,value|
        {
          :type =>  :special,
          :start  =>  value,
          :interval => 7,
        }
      end
    end


    def scan_for_units(token)
      scanner = {
        /^year(?:ly)?s?$/   =>  {
                                  :type     => :year,
                                  :interval => 365,
                                  :start    => :today
                                },
        /^month(?:ly|s)?$/  =>  {
                                  :type     => :month,
                                  :interval => 30,
                                  :start    => :today
                                },
        /^fortnights?$/     =>  {
                                  :type     => :fortnight,
                                  :interval => 14,
                                  :start    => :today
                                },
        /^week(?:ly|s)?$/   =>  {
                                  :type     => :week,
                                  :interval => 7,
                                  :start    => :today
                                },
        /^weekends?$/       =>  {
                                  :type     => :weekend,
                                  :interval => 7,
                                  :start    => :saturday
                                },
        /^days?$/           =>  {
                                  :type     => :day,
                                  :interval => 1,
                                  :start    => :today
                                },
        /^daily$/           =>  {
                                  :type     => :day,
                                  :interval => 1,
                                  :start    => :today
                                },
        /^sec(?:onds)?$/    =>  {
                                  :type     => :sec,
                                  :interval => 1,
                                  :start    => :today
                                },
      }

      detection token, scanner do |md,key,value|
        value
      end
    end


  end
end
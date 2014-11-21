#=============================================================================
#
#  Name:       Tickle
#  Author:     Joshua Lippiner
#  Purpose:    Parse natural language into recuring intervals
#
#=============================================================================


$LOAD_PATH.unshift(File.dirname(__FILE__))     # For use/testing when no gem is installed

require 'date'
require 'time'
require 'chronic'

require 'tickle/tickle'
require 'tickle/handler'
require 'tickle/repeater'
require_relative "ext/array.rb"
require_relative "ext/date_and_time.rb"

# Tickle is a natural language parser for recurring events.
module Tickle

  def self.debug=(val); @debug = val; end

  def self.dwrite(msg, line_feed=nil)
    (line_feed ? p(">> #{msg}") : puts(">> #{msg}")) if @debug
  end

  def self.is_date(str)
    begin
      Date.parse(str.to_s)
      return true
    rescue Exception => e
      return false
    end
  end
end

class String
  # returns true if the sending string is a text or numeric ordinal (e.g. first or 1st)
  def is_ordinal?
    scanner = %w{first second third fourth fifth sixth seventh eighth ninth tenth eleventh twelfth thirteenth fourteenth fifteenth sixteenth seventeenth eighteenth nineteenth twenty thirty thirtieth}
    regex = /\b(\d*)(st|nd|rd|th)\b/
    !(self =~ regex).nil? || scanner.include?(self.downcase)
  end

  def ordinal_as_number
    return self unless self.is_ordinal?
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
    result = self
    scanner.keys.each {|scanner_item| result = scanner[scanner_item] if scanner_item =~ self}
    return result.gsub(/\b(\d*)(st|nd|rd|th)\b/, '\1')
  end
end
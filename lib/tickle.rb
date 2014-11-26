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
require_relative "ext/string.rb"

# Tickle is a natural language parser for recurring events.
module Tickle


  def self.is_date(str)
    begin
      Date.parse(str.to_s)
      return true
    rescue Exception => e
      return false
    end
  end
end
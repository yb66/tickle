
require File.join(File.dirname(__FILE__), 'lib', 'tickle')

=begin

Time is ignored if there's also a date, unless the date is 'tomorrow'(?)

Tickle creates times in the servers local time zone.
To go from server time to user's local time...
  user_time = server_time + (user_time_offset - server_time_offset)
  eg (5:00PM Central) = (6:00PM Eastern + (-6 - -5))

=end


server_offset = Time.now.utc_offset / 60 / 60

['May 30th at midnight', '6:30 PM', 
 'tomorrow at 6:00', 'June 18, 2011', 'Christmas'].each {|s|
  time = Tickle.parse(s)[:next]
  print s, " --> server date: ", time
  puts
  print s, " --> utc date: ", time.utc
  puts
}
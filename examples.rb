
require File.join(File.dirname(__FILE__), 'lib', 'tickle')

['May 30', '6:30 PM', 'tomorrow at 6:00', 'June 18, 2011',].each {|s|
    print "s: ", s, " ", Tickle.parse(s)
    puts
}
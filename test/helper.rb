require 'simplecov'
SimpleCov.start do
  add_filter "/vendor/"
  add_filter "/bin/"
end

require 'test/unit'
require 'shoulda'
require 'timecop'


$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require File.join(File.dirname(__FILE__), '..', 'lib', 'tickle')

class Test::Unit::TestCase
end

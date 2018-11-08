# encoding: UTF-8

require 'rspec'
require 'rspec/its'
require 'rspec/given'
Spec_dir = File.expand_path( File.dirname __FILE__ )

# code coverage
require 'simplecov'
SimpleCov.start do
  add_filter "/vendor/"
  add_filter "/vendor.noindex/"
  add_filter "/bin/"
  add_filter "/spec/"
  add_filter "/coverage/" # It used to do this for some reason, defensive of me.
end


Dir[ File.join( Spec_dir, "/support/**/*.rb")].each do |f|
  require f
end

Time_now = Time.parse "2010-05-09 20:57:36 +0000"

require 'timecop'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  tz = ENV["TZ"]
  config.before(:all, :frozen => true) do
    Timecop.freeze Time_now
    ENV["TZ"] = "UTC"
  end
  config.after(:all, :frozen => true) do
    Timecop.return
    ENV["TZ"] = tz
  end
end

warn "Actual Time now => #{Time.now}"


if ENV["DEBUG"]
  warn "DEBUG MODE ON"
  require 'pry-byebug'
  require 'pry-state'
  binding.pry
end
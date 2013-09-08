# encoding: UTF-8

require 'rspec'
Spec_dir = File.expand_path( File.dirname __FILE__ )


# code coverage
require 'simplecov'
SimpleCov.start do
  add_filter "/vendor/"
  add_filter "/bin/"
  add_filter "/spec/"
end


Dir[ File.join( Spec_dir, "/support/**/*.rb")].each do |f|
  require f
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

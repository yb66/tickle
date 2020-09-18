# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tickle/version'

Gem::Specification.new do |s|
  s.name = %q{tickle}
  s.version = Tickle::VERSION

  s.authors = ["Joshua Lippiner", "Iain Barnett"]
  s.email = %q{iainspeed@gmail.com}
  s.description = %q{Tickle is a date/time helper gem to help parse natural language into a recurring pattern.  Tickle is designed to be a compliment of Chronic and can interpret things such as "every 2 days, every Sunday, Sundays, Weekly, etc.}
  s.summary = %q{natural language parser for recurring events}
  s.homepage = %q{http://github.com/yb66/tickle}
  s.license       = "MIT"

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  
  s.require_paths = ["lib"]

  s.add_dependency "gitlab-chronic", "~> 0.10.6"
  s.add_dependency "numerizer", "~> 0.2.0"
  s.add_development_dependency "shoulda", "~> 2.10.3"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "test-unit"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "yard"
  s.add_development_dependency "maruku"
  s.add_development_dependency "timecop"
end


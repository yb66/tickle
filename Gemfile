source "https://rubygems.org"

gemspec

group :development do
  gem "maruku"
  gem "yard"
  unless RUBY_ENGINE == 'jruby'
    gem "pry-byebug"
    gem "pry-state"
  end
end

group :test do
  gem "rspec"
  gem "rspec-its"
  gem "timecop"
  gem "simplecov"
  gem "rake"
end
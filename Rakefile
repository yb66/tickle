require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec


desc "(Re-) generate documentation and place it in the docs/ dir. Open the index.html file in there to read it."
task :docs => [:"docs:environment", :"docs:yard"]
namespace :docs do

  task :environment do
    ENV["RACK_ENV"] = "documentation"
  end

  require 'yard'

  YARD::Rake::YardocTask.new :yard do |t|
    t.files   = ['lib/**/*.rb']
    t.options = ['-odoc/'] # optional
  end

end

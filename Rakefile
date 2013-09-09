require 'rspec/core/rake_task'

Dir.glob(File.expand_path('../lib/tasks/*.rake', __FILE__)).each { |f| load f }

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

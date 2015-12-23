require 'bundler/gem_tasks'
load 'lib/rake_tasks/docker.rake'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
# ignored
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop)
rescue LoadError
# ignored
end

task default: [:spec, :rubocop]

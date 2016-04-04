require 'bundler/gem_tasks'
load 'lib/rspec/rake_tasks/docker.rake'

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  RSpec::Core::RakeTask.new(:hive_spec) do |t|
    t.pattern = 'examples/**/*_spec.rb'
  end
rescue LoadError
  puts 'Cannot load rspec Rake tasks'
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop)
rescue LoadError
  puts 'Cannot load RuboCop Rake tasks'
end

task default: [:spec, :rubocop]

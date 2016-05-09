require 'bundler/gem_tasks'
load 'lib/rspec/hive/rake_tasks/docker.rake'

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

detect_docker = <<-BASH
  CONTAINER_IDS=`docker ps -q --filter='ancestor=nielsensocial/hive' 2> /dev/null | xargs`
  docker inspect --format='{{ .State.Running }}' $CONTAINER_IDS 2> /dev/null | uniq | grep true 2>&1 > /dev/null
BASH

if system(detect_docker)
  task default: [:spec, :hive_spec, :rubocop]
else
  task default: [:spec, :rubocop]
end

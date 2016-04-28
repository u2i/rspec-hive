# A sample Guardfile
# More info at https://github.com/guard/guard#readme

detect_docker = <<-BASH
  CONTAINER_IDS=`docker ps -q --filter='ancestor=nielsensocial/hive' 2> /dev/null | xargs`
  docker inspect --format='{{ .State.Running }}' $CONTAINER_IDS 2> /dev/null | uniq | grep true 2>&1 > /dev/null
BASH

group :red_green_refactor, halt_on_fail: true do
  guard :rspec, cmd: 'bundle exec rspec' do
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch('spec/spec_helper.rb') { 'spec' }
  end

  guard :rspec, cmd: 'bundle exec rspec', spec_paths: ['examples/spec'] do
    watch(%r{^examples/spec/.+_spec\.rb$})
    watch(%r{^examples/lib/(.+)\.rb$}) { |m| "examples/spec/#{m[1]}_spec.rb" }
    watch('examples/spec/spec_helper.rb') { 'examples/spec' }
  end if system(detect_docker)

  guard :rubocop, all_on_start: false do
    watch(%r{.+\.rb$})
    watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
  end
end

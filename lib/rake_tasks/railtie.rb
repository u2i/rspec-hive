require 'rails'

module HiveTests
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'rake_tasks/docker.rake'
    end
  end
end

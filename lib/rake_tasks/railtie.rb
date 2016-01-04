require 'rails'

module HiveTests
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'docker.rake'
    end
  end
end
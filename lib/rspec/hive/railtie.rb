# frozen_string_literal: true

require 'rails'

module RSpec
  module Hive
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load 'rspec/hive/rake_tasks/docker.rake'
      end
    end
  end
end

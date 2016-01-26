require_relative 'rake_includer'

namespace :hive_tests do
  namespace :config do
    desc 'Generates example config file. Accepts directory to file.'
    task :generate_default do
      ConfigGeneratorHelper.generate_config
    end
  end

  namespace :docker do
    desc 'Runs docker using hive config file.'\
          ' It assumes your docker-machine is running.'
    task :run do
      DockerHelper.run_docker
    end

    desc 'Downloads docker image from dockerhub.'
    task :download_image do
      DockerHelper.download_image
    end
  end
end

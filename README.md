[![Code Climate](https://codeclimate.com/repos/567b03d7bd3f3b2512002248/badges/85abbc07acb75f664185/gpa.svg)](https://codeclimate.com/repos/567b03d7bd3f3b2512002248/feed)
[![Test Coverage](https://codeclimate.com/repos/567b03d7bd3f3b2512002248/badges/85abbc07acb75f664185/coverage.svg)](https://codeclimate.com/repos/567b03d7bd3f3b2512002248/coverage)
[![Issue Count](https://codeclimate.com/repos/567b03d7bd3f3b2512002248/badges/85abbc07acb75f664185/issue_count.svg)](https://codeclimate.com/repos/567b03d7bd3f3b2512002248/feed)

# HiveTests

HiveTests is a utility gem to help you write beautiful rspec tests for hive queries. The idea is simple - you just launch a docker machine with hadoop and hive installed. To test a query you create a simple RSpec file and extend it with `HiveTests::WithHiveConnection`.

We have prepared a few simple rake tasks that will let you create sample config file, download correct docker image and run docker container with proper parameters.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hive_tests'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hive_tests

### Configuring tests

#### Config file

To run tests on docker you will need a configurtion file that will let you put up a docker container and maintain your connection to this container from tests. You can do this manually and provide just a path to file, but we have also prepared special rake tasks to help you out. Try running:

    $ rake hive_tests:config:generate_default

It will create `hive_tests_config.yml` in your current directory. You can of course pass some parameters to this rake task doing something like:

    $ rake hive_tests:config:generate_default HOST=127.0.0.1 PORT=5032

You can specify following arguments:
* HOST - ip of docker container
* PORT - port to connect to docker
* HOST_SHARED_DIR - directory on your local machine that docker will share
* DOCKER_SHARED_DIR - directory on your docker container that will be shared with your local machine
* HIVE_VERSION - version of hive
* CONFIG_FILE_DIR - directory where to put generated config file
* CONFIG_FILE_NAME - name of the config file that will be generated

#### Docker image
Once you have generated a config file you should download to your local machine proper docker image. You can create your own docker image. However if you would like to use ours just run:

    $ rake hive_tests:docker:download_image
    
It will download `nielsensocial/hive` from [dockerhub](https://hub.docker.com/r/nielsensocial/hive/).
If you have another image you can also use this rake task and provide special argument:
* DOCKER_IMAGE_NAME - image name that should be pulled
 
#### Running docker container
You should now be ready to run your docker container. To do this run:

    $ rake hive_tests:docker:run

This command will run docker container using default config `hive_tests_config.yml` and default docker image `nielsensocial/hive`. You can pass arguments like:
* CONFIG_FILE - name of config file to use
* DOCKER_IMAGE_NAME - docker image to use

You are ready now to run your tests.

#### Docker utils

To check container id

`$ docker ps`

To attach to output of hive

`$ docker attach <docker-container-id>`

To run bash terminal on docker

`$ docker exec -it <docker-container-id> bash`

## Usage

In `examples/` directory we have prepared a simple query. It is available in `query_spec.rb` file. Notice how we configure `hive_tests` by using:
    
    require_relative 'config_helper'

Where we invoke:
    
    HiveTests.configure(File.join(__dir__, './../hive_tests_config.yml'))

## Contributing

1. Fork it ( https://github.com/[my-github-username]/hive_tests/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[![Build Status](https://travis-ci.org/u2i/rspec-hive.svg?branch=master)](https://travis-ci.org/u2i/rspec-hive)
[![Dependency Status](https://gemnasium.com/u2i/rspec-hive.svg)](https://gemnasium.com/u2i/rspec-hive)
[![Code Climate](https://codeclimate.com/repos/567b03d7bd3f3b2512002248/badges/85abbc07acb75f664185/gpa.svg)](https://codeclimate.com/repos/567b03d7bd3f3b2512002248/feed)
[![Test Coverage](https://codeclimate.com/repos/567b03d7bd3f3b2512002248/badges/85abbc07acb75f664185/coverage.svg)](https://codeclimate.com/repos/567b03d7bd3f3b2512002248/coverage)
[![Issue Count](https://codeclimate.com/repos/567b03d7bd3f3b2512002248/badges/85abbc07acb75f664185/issue_count.svg)](https://codeclimate.com/repos/567b03d7bd3f3b2512002248/feed)

# rpsec-hive

rspec-hive is a utility gem to help you write beautiful rspec tests for hive queries. The idea is simple - you just launch a docker machine with hadoop and hive installed. To test a query you create a simple RSpec file and extend it with `RSpec::Hive::WithHiveConnection`.

We have prepared a few simple rake tasks that will let you create sample config file, download correct docker image and run docker container with proper parameters.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-hive'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-hive

### Configuring tests

#### Config file

To run tests on docker you will need a configurtion file that will let you put up a docker container and maintain your connection to this container from tests. You can do this manually and provide just a path to file, but we have also prepared special rake tasks to help you out. Try running:

    $ rake spec:hive:config:generate_default

It will create `rspec-hive.yml` in your current directory. You can of course pass some parameters to this rake task doing something like:

    $ rake spec:hive:config:generate_default HOST=127.0.0.1 PORT=5032

You can specify following arguments:
* HOST - ip of docker container
* PORT - port to connect to docker
* HOST_SHARED_DIR - directory on your local machine that docker will share
* DOCKER_SHARED_DIR - directory on your docker container that will be shared with your local machine
* HIVE_VERSION - version of hive
* CONFIG_FILE_DIR - directory where to put generated config file
* CONFIG_FILE_NAME - name of the config file that will be generated

#### Installing Docker
Detailed instruction may be found on https://docs.docker.com/engine/installation.

Once docker is sucessfully installed on your machine you can verify if it works by using `docker` command.
In case of error such as `Cannot connect to the Docker daemon. Is the docker daemon running on this host?` make sure you added your user to the docker group, you can do this using `sudo usermod -aG docker username` on Linux or `eval "$(docker-machine env default)"` on OSX.

On Linux you can run the docker daemon by using:
`sudo docker daemon -D -g /mnt`

#### Docker image
Once you have generated a config file you should download to your local machine proper docker image. You can create your own docker image. However if you would like to use ours just run:

    $ rake spec:hive:docker:download_image

It will download `nielsensocial/hive` from [dockerhub](https://hub.docker.com/r/nielsensocial/hive/).
You can change Docker's storage base directory (where container and images go) using the -goption when starting the Docker daemon.
If you have another image you can also use this rake task and provide special argument:
* DOCKER_IMAGE_NAME - image name that should be pulled


#### Running docker container
You should now be ready to run your docker container. To do this run:

    $ rake spec:hive:docker:run

This command will run docker container using default config `rspec-hive.yml` and default docker image `nielsensocial/hive`. You can pass arguments like:
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

#### Hive utils

When you are on hive and you have set up `JAVA_HOME` and `HADOOP_HOME` directories you might find usefull the tool named beeline. It should be present in your hive directory in `bin` folder (if you are using ours `nielsensocial/hive` when you run bash terminal on docker container this directory could be entered by calling `cd $HIVE_HOME/bin`). There you can run:

    $ ./beeline

And in the presented console connect by jdbc to hive:

    beeline> !connect jdbc:hive2://localhost:10000 org.apache.hive.jdbc.HiveDriver

## Usage

In `examples/` directory we have prepared a simple query. It is available in `query_spec.rb` file. Notice how we configure `rspec-hive` by using:

    require_relative 'config_helper'

Where we invoke:

    RSpec::Hive.configure(File.join(__dir__, '/config.yml'))

## Note

Please remember docker does not remove containers automatically, use `docker ps -a` to list all unused containers.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rspec-hive/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

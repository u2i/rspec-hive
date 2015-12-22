# HiveTests

HiveTests is a utility gem to help you write beautiful rspec tests for hive queries. The idea is simple - you just launch a docker machine with hadoop and hive installed (on tips how to do it check out our example Dockerfile), then call `HiveTests.configure` with config of host, port and shared directories of this docker machine and finally just extend a spec with `HiveTests::WithHiveConnection`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hive_tests'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hive_tests
### Setting up docker

To build docker enter directory with Dockerfile and run

`$ docker build -t <docker-name>`

Then run docker machine with proper port mapping and setting up shared directory. For more information see - [docker documentation](https://docs.docker.com/engine/userguide/dockervolumes/)

`$ docker run -v <host_shared_folder>:<docker_shared_folder> -d -p <host_port>:<docker_port> <docker-name> `

Remember that you have also to set up proper configurtaion so that you can communicate with hive instance on docker.

#### Docker utils

To check container id

`$ docker ps`

To attach to output of hive

`$ docker attach <docker-container-id>`

To run bash terminal on docker

`$ docker exec -it <docker-container-id> bash`

## Usage

Check `examples/`

## Contributing

1. Fork it ( https://github.com/[my-github-username]/hive_tests/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

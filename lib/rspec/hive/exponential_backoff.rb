require 'retryable'

module RSpec
  module Hive
    class ExponentialBackoff
      class << self
        def retryable(tries: 5, on:)
          Retryable.retryable(tries: tries, sleep: ->(r) { 2**r }, on: on) do
            yield
          end
        end
      end
    end
  end
end

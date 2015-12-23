require 'securerandom'

module HiveTests
  class DbName
    class << self
      def random_name
        "#{timestamp}_#{random_key}"
      end

      private

      def timestamp
        Time.now.getutc.to_i.to_s
      end

      def random_key
        SecureRandom.uuid.delete('-')
      end
    end
  end
end

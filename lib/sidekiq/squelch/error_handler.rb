module Sidekiq
  module Squelch
    class ErrorHandler
      attr_accessor :notifier

      def initialize(notifier)
        @notifier = notifier
      end

      def call(ex, context)
        increment_exception_counter ex
        notifier.notify ex, context unless squelched? ex 
      end

      private

      def squelched?(ex)
        config = config_for ex
        return false unless config

        time = (Time.now - config[:period]).to_f
        key = key_for ex
        
        count = Sidekiq.redis do |redis|
          redis.zremrangebyscore key, '-inf', time
          redis.zcount key, '-inf', '+inf'
        end

        count < config[:threshold]
      end

      def increment_exception_counter(ex)
        return unless config_for ex

        time = Time.now.to_f
        key = key_for ex
        value = { thrown_at: time, message: ex.message }.to_json

        Sidekiq.redis { |redis| redis.zadd key, time, value }
      end

      def config_for(ex)
        return unless Sidekiq.options[:squelch]

        config = Sidekiq.options[:squelch].find { |s| s.first.to_s == ex.to_s }
        return unless config

        Hash[[:error, :threshold, :period].zip config]
      end

      def key_for(ex)
        [:squelch, ex.class.to_s.underscore].join(':')
      end
    end
  end
end

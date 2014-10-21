module Sidekiq
  module Squelch
    class Middleware
      def initialize(notifier)
        @notifier = notifier
      end

      def call(worker, msg, queue)
        yield
      rescue => ex
        @handler ||= ErrorHandler.new
        @handler.notifier = @notifier

        @handler.call ex, {}

        raise
      end
    end
  end
end

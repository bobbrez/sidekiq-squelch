module Sidekiq
  module Squelch
    module Notifiers
      class Raven
        def notify(exception, context = {})
          ::Raven.capture_exception exception, extra: { sidekiq: context }
        end
      end
    end
  end
end

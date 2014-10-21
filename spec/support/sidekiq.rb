require 'sidekiq'

Sidekiq.logger = nil
Sidekiq.redis = { namespace: 'test' }

require 'sidekiq'
require 'raven/base'
require './lib/sidekiq/squelch'
require 'byebug'

class CaughtError < StandardError; end
class UncaughtError < StandardError; end

class DerpyWorker
  include Sidekiq::Worker

  def perform(ex)
    raise CaughtError if ex == 'caught'
    raise UncaughtError
  end
end

Raven.configure do |config|
  config.dsn = 'https://7d3e06e5127f4f5e804584b7ab79c0b4:c19b1bb109e7470c9fe029fd6776e925@app.getsentry.com/31722'
end

handler = Sidekiq::Squelch::ErrorHandler.new Sidekiq::Squelch::Notifiers::Raven.new

Sidekiq.configure_server do |config|
  config.error_handlers << handler
end

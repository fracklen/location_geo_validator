require 'raven'

Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN'] if ENV['SENTRY_DSN']
  config.silence_ready = true
  config.logger = ::Logger.new('/dev/null')
end

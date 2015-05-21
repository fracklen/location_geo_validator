require 'lbunny'
require_relative 'location'

class RabbitClient
  attr_reader :handler

  def initialize(handler)
    @handler = handler
  end

  def subscribe!
    client.subscribe(
      "dk.location_geo_validator",
      "dk.location.updated",
      subscribe_options
    ) do |_, metadata, payload|
      handler.if_violated(JSON.parse(payload)) do |error_info|
        publish(error_info)
      end
    end
  rescue Interrupt
    :noop
  rescue => e
    Raven.capture_exception(e, error_message: "Cant subscribe in #{self}: #{e}")
  end

  def publish(error_info)
    client.publish(error_info.to_json, options)
  end

  def client
    @client ||= Lbunny::Client.new(rabbit_url) do |error|
      Raven.capture_exception(error)
    end
  end

  def rabbit_url
    ENV['RABBITMQ_URL'] || "amqp://guest:guest@localhost:5672"
  end

  def options
    {
      routing_key:  'dk.location_geo.failed',
      type:         "location.geo_validation.failed",
      app_id:       "dk.location_geo_validator",
      persistent:   true,
      content_type: 'application/json',
      timestamp:    Time.now.to_i
    }
  end

  def subscribe_options
    {
      block: true
    }
  end
end

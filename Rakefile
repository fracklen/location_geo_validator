require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'net/http'
require 'json'
require 'map'
require 'geo_ruby'
require 'pstore'
require 'time'
require 'require_all'
require_all 'config'
require_all 'lib'

namespace :validate do

  desc "Verifies that coordinates of locations are within the boundary their assigned postal code"
  task :coordinates do
    postal_code_service = PostalCodeService.new
    validator = Validator.new(postal_code_service)
    event_handler = UpdatedEventHandler.new(validator)
    rabbit_client = RabbitClient.new(event_handler)
    rabbit_client.subscribe!
  end

  desc "This task must be run once, before starting other sync tasks"
  task :set_postal_cache do
    postal_code_service = PostalCodeService.new
    postal_code_service.update_postal_codes_in_store
  end
end

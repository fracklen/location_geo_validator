require 'yaml'

class UpdatedEventHandler
  attr_reader :validator

  def initialize(validator)
    @validator = validator
  end

  def if_violated(location_data)
    location = Location.new(location_data)
    unless validator.valid?(location)
      yield validator.error_info(location)
    end
  end
end

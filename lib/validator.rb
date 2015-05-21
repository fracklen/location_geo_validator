class Validator
  attr_reader :postal_code_service

  def initialize(postal_code_service)
    @postal_code_service = postal_code_service
  end

  def valid?(location)
    begin
      return within?(location)
    rescue Exception => e
      Raven.capture_exception(e, error_message: "Location uuid: #{location.uuid}")
      return false
    end
  end

  def error_info(location)
    pc = postal_code(location)
    pd = postal_district(pc)

    begin
      puts "\n******** SUSPECT **********".fg("yellow")
      puts "#{location.address_line1}, #{location.postal_code} #{location.postal_name}".fg("white").bright
      puts "#{location.latitude}, #{location.longitude}".fg("white").bright
      puts "Looks to be situated in: #{pd.nr} #{pd.navn}".fg("white").bright
    rescue
      :noop
    end

    {
      location_id: location.id,
      location_uuid: location.uuid,
      position_postal_code: pc,
      position_postal_district: postal_district_info(pd),
      distance: distance(location),
    }
  end

  private

  def within?(location)
    postal_code_service
      .contains?(
        location.postal_code.strip,
        [
          location.longitude,
          location.latitude
        ]
      )
  end

  def distance(location)
    postal_code_service.distance(location.postal_code.strip, [location.longitude, location.latitude])
  end

  def postal_code(location)
    postal_code_service.find_postal_code_by_coordinate([location.latitude, location.longitude])
  end

  def postal_district(postal_code)
    postal_code_service.postal_district(postal_code)
  end

  def postal_district_info(postal_district)
    return nil if postal_district.nil?
    {
      name:   postal_district.navn,
      number: postal_district.nr
    }
  end
end

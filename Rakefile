require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'net/http'
require 'json'
require 'map'
require 'geo_ruby'
require 'pstore'
require 'pry'
require 'tco'
require 'require_all'
require_all 'lib'

namespace :validate do

  task :test do
    as = AdvertService.new
    locations = as.locations("dk", "user_sale", "all")
    puts locations.first
  end

  # desc "Postal coes"
  # task :postal_codes do
  #   as = AdvertService.new
  #   locations = as.locations("dk", "lease", "all")
  #   puts locations.length
  # end

  desc "Verifies that coordinates of locations are within their boundary their postal code"
  task :coordinates do
    advert_service = AdvertService.new
    postal_code_service = PostalCodeService.new
    validate_coordinates(advert_service, postal_code_service, "user_sale")
    validate_coordinates(advert_service, postal_code_service, "investment_sale")
    validate_coordinates(advert_service, postal_code_service, "lease")
  end

  def validate_coordinates(advert_service, postal_code_service, type)
    suspects = 0
    counter = 0

    print "Loading locations...".fg("#c0c0c0").bright
    locations = advert_service.locations("dk", type, "all")
    puts "#{locations.length} loaded".fg("green").bright
    puts "\n       VALIDATING #{type}       ".bg("#2d3091").fg("#ffffff").bright
    locations.each do |location|
      begin
        # print "."
        unless postal_code_service.contains?(location.postal_code.strip, [location.longitude, location.latitude])
          pc = postal_code_service.find_postal_code_by_coordinate([location.latitude, location.longitude])
          pd = postal_code_service.postal_district(pc)
          suspects += 1
          puts "\n******** SUSPECT **********".fg("yellow")
          puts "#{location.address_line_1}, #{location.postal_code} #{location.postal_name}".fg("white").bright
          puts "#{location['_links']['self']['href']}".fg("white").bright
          puts "#{location.latitude}, #{location.longitude}".fg("white").bright
          puts "Looks to be situated in: #{pd.nr} #{pd.navn}".fg("white").bright
        end
      rescue Exception => e
        puts e
        puts "#{location.address_line_1}, #{location.postal_code} #{location.postal_name}".fg("#ff0000").bright
        puts "#{location.latitude}, #{location.longitude}".fg("#ff0000").bright
        raise
      end
    end
    print "\n#{locations.length} verified".fg("#c0c0c0")
    puts " - #{suspects} suspects".fg("red")
  end

end
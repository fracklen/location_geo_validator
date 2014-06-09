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
require 'time'
require 'require_all'
require_all 'lib'

namespace :validate do

  desc "Verifies that coordinates of locations are within the boundary their assigned postal code"
  task :coordinates do
    advert_service = AdvertService.new
    postal_code_service = PostalCodeService.new
    reports = { sub_reports: [], created_date: DateTime.now.to_s }
    reports[:sub_reports] << validate_coordinates(advert_service, postal_code_service, "user_sale")
    reports[:sub_reports] << validate_coordinates(advert_service, postal_code_service, "investment_sale")
    reports[:sub_reports] << validate_coordinates(advert_service, postal_code_service, "lease")
    puts JSON.dump reports
  end

  def validate_coordinates(advert_service, postal_code_service, category)

    report = { suspects: [], category: category }
    suspects = 0
    counter = 0

    puts "\n       VALIDATING #{category}       ".bg("#2d3091").fg("#ffffff").bright
    print "Loading locations...".fg("#c0c0c0").bright
    locations = advert_service.locations("dk", category, "all")
    puts "#{locations.length} loaded".fg("green").bright
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
          location[:postal_district_by_coordinate] = pd
          report[:suspects] << location
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
    report[:total_number_of_locations] = locations.length
    report[:total_number_of_suspects] = suspects
    report
  end

end

require_relative './http_client'
require 'tco'

class PostalCodeService

  attr_reader :store, :postal_codes, :polygons

  def initialize(store = PStore.new("postal_borders.pstore"))
    @store = store
    init_postal_codes
    init_polygons
  end

  def find_postal_code_by_coordinate(coordinates)
    @polygons.keys.each do |postal_code|
      return postal_code.strip if contains?(postal_code, coordinates.reverse)
    end
    nil
  end

  def postal_district(postal_code)
    @postal_codes.select{|pc| pc.nr == postal_code.to_s }.first
  end

  def borders(postal_code)
    return @polygons[postal_code] if @polygons.has_key?(postal_code)
    res = nil
    store.transaction do |s|
      s[postal_code] = postal_borders(postal_code) unless s.root?(postal_code)
      res = s[postal_code]
    end
    res
  end

  def distance(postal_code, coordinate)
    0 if contains?(postal_code, coordinate)
    borders(postal_code).map do |polygon_coord|
      postal_area = GeoRuby::SimpleFeatures::Polygon.from_coordinates(polygon_coord,256)
      location = GeoRuby::SimpleFeatures::Point.from_x_y(coordinate[0], coordinate[1])
      first = postal_area.bounding_box[0].spherical_distance(location)/1000
      second = postal_area.bounding_box[1].spherical_distance(location)/1000
      [first, second].min
    end.min
  end

  def contains?(postal_code, coordinate)
    borders(postal_code).any? do |polygon_coord|
      postal_area = GeoRuby::SimpleFeatures::Polygon.from_coordinates(polygon_coord,256)
      location = GeoRuby::SimpleFeatures::Point.from_x_y(coordinate[0], coordinate[1])
      postal_area.contains_point?(location)
    end
  end

  def update_postal_codes_in_store
    @postal_codes.each do |pc|
      puts "PC: #{pc['nr']}"
      update_cache(pc['nr']) unless @polygons.has_key?(pc['nr'])
    end
  end

  private

    def postal_borders(postal_code)
      print "\n>#{postal_code}"
      res = Map.new perform_get(postal_borders_url(postal_code))
      puts "<"
      res['coordinates']
    end

    def init_postal_codes
      print "Init postalcodes...".fg("#c0c0c0").bright
      @postal_codes = perform_get(postal_codes_url).map{ |pc| Map.new(pc) }
      puts "finished".fg("green").bright
    end

    def init_polygons
      print "Init polygons...".fg("#c0c0c0").bright
      @polygons = {}
      store.transaction(true) do |s|
        postal_codes = s.roots
        postal_codes.each do |postal_code|
          @polygons[postal_code] = s[postal_code]
        end
      end
      puts "finished".fg("green").bright
    end

    def update_cache(postal_code)
      store.transaction do |s|
        s[postal_code] = postal_borders(postal_code)
      end
    end

    def perform_get(url)
      HttpClient.new.perform_get(url)
    end

    def postal_codes_url
      "http://geo.oiorest.dk/postnumre.json"
    end

    def postal_borders_url(postal_code)
      "http://geo.oiorest.dk/postnumre/#{postal_code}/gr%C3%A6nse.json"
    end

end

require_relative './http_client'

class AdvertService

  def locations(site, category, kind)
    locations = HttpClient.new.perform_get(url(category, kind), { 'site' => site } )
    locations.map{ |loc| Map.new(loc) }
  end

  private

    def url(category, kind)
      "http://advert-service.services.lokalebasen.dk/adverts/#{category}/#{kind}"
    end

    def response(url, req)
      Net::HTTP.start(URI(url).hostname, URI(url).port) {|http|
        http.request(req)
      }
    end

end

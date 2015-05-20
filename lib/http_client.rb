require "open-uri"
require 'net/https'

class HttpClient

  def perform_get(url, header_params = {})
    body = open(url, header_params) {|f|
      f.read
    }
    JSON.load body
  end

  def perform_post(url, json)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl=(uri.scheme=="https")
    req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
    req.body = json
    http.request(req).body
  end

  private

    def add_header_params(request, header_params)
      header_params.keys.each do |key|
        request[key] = header_params[key]
      end
    end

    def response(url, req)
      Net::HTTP.start(URI(url).hostname, URI(url).port) {|http|
        http.request(req)
      }
    end

end

class HttpClient

  def perform_get(url, header_params = {})
    request = Net::HTTP::Get.new(URI(url).request_uri)
    add_header_params(request, header_params)
    JSON.load response(url, request).body
  end

  def perform_post(url, json)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
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
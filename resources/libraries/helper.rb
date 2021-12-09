module Rbscanner
  module Helper
    require 'net/http'
    require 'uri'
    require 'json'

    def get_consul_service_ip(service, host = "localhost", port = "8500")
      query = "/v1/catalog/service/#{service}"
      uri = URI.parse("http://#{host}:#{port}#{query}")
      request = Net::HTTP::Get.new(uri)
      response = JSON.parse(api_request(request, uri).body)
      map_response(response, "Address")
    end

    def map_response(response, filter)
      response.first.to_hash["#{filter}"]
    end

    def api_request(request, uri)
      response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(request)
      end
      return response
    end

  end
end
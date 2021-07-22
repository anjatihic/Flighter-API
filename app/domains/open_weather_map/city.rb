module OpenWeatherMap
  class City
    KELVIN_ZERO_CELSIUS = 273.15
    API_URL = 'https://api.openweathermap.org/data/2.5/find'
    include Comparable
    attr_accessor :id, :lat, :lon, :name, :temp_k

    def initialize(id:, lat:, lon:, name:, temp_k:)
      @id = id
      @lat = lat
      @lon = lon
      @temp_k = temp_k.round(2)
      @name = name
    end

    def temp
      (temp_k - KELVIN_ZERO_CELSIUS).round(2)
    end

    def <=>(other)
      temp_k == other.temp_k ? name <=> other.name : temp_k <=> other.temp_k
    end

    def nearby(num_of_cities = 5)
      response = response(num_of_cities)
      response = JSON.parse(response.body)
      nearby_cities = response['list']
      nearby_cities.map { |city_hash| OpenWeatherMap::City.parse(city_hash) }
    end

    def coldest_nearby(*args)
      nearby(*args).min
    end

    def response(num_of_cities)
      Faraday.get(API_URL.to_s) do |req|
        req.params['lat'] = lat
        req.params['lon'] = lon
        req.params['cnt'] = num_of_cities
        req.params['appid'] = Rails.application.credentials.open_weather_map_api_key
      end
    end

    def self.parse(params = {})
      lat = params.dig('coord', 'lat')
      lon = params.dig('coord', 'lon')
      temp_k = params.dig('main', 'temp')
      id = params['id']
      name = params['name']

      new(id: id, lat: lat, lon: lon, name: name, temp_k: temp_k)
    end
  end
end

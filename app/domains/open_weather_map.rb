module OpenWeatherMap
  API_URL = 'https://api.openweathermap.org/data/2.5/'

  def self.city(city_name)
    id = Resolver.city_id(city_name)
    return nil if id.nil?

    response = parsed_response('weather', id)
    City.parse(response)
  end

  def self.cities(cities)
    city_ids = cities.map { |city| Resolver.city_id(city) }
    city_ids = city_ids.compact.join(',')

    response = OpenWeatherMap.parsed_response('group', city_ids)
    cities_objects = []
    response['list'].each { |city| cities_objects << City.parse(city) }
    cities_objects
  end

  def self.parsed_response(type, city_id)
    response = Faraday.get("#{API_URL}#{type}") do |req|
      req.params['id'] = city_id
      req.params['appid'] = Rails.application.credentials.open_weather_map_api_key
    end
    JSON.parse(response.body)
  end
end

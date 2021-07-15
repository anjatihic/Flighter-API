module OpenWeatherMap
  class Resolver
    def city_id(city_name)
      city_file = File.read(File.expand_path('city_ids.json', __dir__))
      city_hash = JSON.parse(city_file)
      found_city = city_hash.find { |city| city['name'] == city_name }
      found_city.nil? ? nil : found_city['id']
    end
  end
end

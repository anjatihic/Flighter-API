module OpenWeatherMap
  class Resolver
    JSON_FILE_NAME = 'city_ids.json'

    def self.city_id(city_name)
      cities_hash = OpenWeatherMap::Resolver.json_to_hash
      found_city = cities_hash.find { |city| city['name'] == city_name }
      found_city&.fetch('id')
    end

    def self.json_to_hash
      json = OpenWeatherMap::Resolver.open_read_json
      JSON.parse(json)
    end

    def self.open_read_json
      json = File.expand_path(JSON_FILE_NAME, __dir__)
      File.read(json)
    end
  end
end

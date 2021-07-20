module OpenWeatherMap
  class Resolver
    JSON_FILE_NAME = 'city_ids.json'

    def self.city_id(city_name)
      cities_data = OpenWeatherMap::Resolver.parse_data
      found_city = cities_data.find { |city| city['name'] == city_name }
      found_city&.fetch('id')
    end

    def self.parse_data
      json = OpenWeatherMap::Resolver.read_file
      JSON.parse(json)
    end

    def self.read_file
      file_path = File.expand_path(JSON_FILE_NAME, __dir__)
      File.read(file_path)
    end
  end
end

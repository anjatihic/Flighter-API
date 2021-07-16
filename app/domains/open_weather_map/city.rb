module OpenWeatherMap
  class City
    include Comparable
    attr_accessor :id, :lat, :lon, :name, :temp_k

    def initialize(id:, lat:, lon:, name:, temp_k:)
      @id = id
      @lat = lat
      @lon = lon
      @temp_k = temp_k.round(2)
      @name = name
    end

    KELVIN_ZERO_CELSIUS = 273.15
    def temp
      (temp_k.round(2) - KELVIN_ZERO_CELSIUS).round(2)
    end

    def <=>(other)
      temp == other.temp ? name <=> other.name : temp <=> other.temp
    end

    def self.parse(params = {})
      lat = params['coord']['lat']
      lon = params['coord']['lon']
      temp_k = params['main']['temp']
      id = params['id']
      name = params['name']

      new(id: id, lat: lat, lon: lon, name: name, temp_k: temp_k)
    end
  end
end

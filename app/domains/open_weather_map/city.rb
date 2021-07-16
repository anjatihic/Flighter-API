module OpenWeatherMap
  class City
    include Comparable
    attr_accessor :id, :lat, :lon, :name, :temp_k

    def initialize(id:, lat:, lon:, name:, temp_k:)
      @id = id
      @lat = lat
      @lon = lon
      @temp_k = temp_k
      @name = name
    end

    KELVIN_ZERO_CELSIUS = 273.15
    def temp
      (temp_k - KELVIN_ZERO_CELSIUS).round(2)
    end

    def <=>(other)
      temp == other.temp ? name <=> other.name : temp <=> other.temp
    end
  end
end

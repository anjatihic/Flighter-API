RSpec.describe OpenWeatherMap do
  describe '#city' do
    it 'transforms JSON response into an OpenWeatherMap::City' do
      city_object = described_class.city('Zagreb')

      expect(city_object.lat).to eq(45.8144)
    end

    it 'returns nil if the city name is not recognised' do
      city_object = described_class.city('some_city')

      expect(city_object).to be_nil
    end
  end

  describe '#cities' do
    it 'returns an array of OpenWeatherMap::City instances' do
      cities_objects = described_class.cities(['Zagreb', 'Berlin', 'Leeds'])

      expect(cities_objects.class).to eq(Array)
    end
  end
end

RSpec.describe OpenWeatherMap do
  describe '#city' do
    it 'transforms JSON response into an OpenWeatherMap::City' do
      city_object = described_class.city('Zagreb')
      expect(city_object.lat).to eq(45.8144)
    end

    it 'returns nil if the city name is not recognised' do
      city_object = described_class.city('nešto_bezveze')
      expect(city_object).to be_nil
    end
  end
end

RSpec.describe OpenWeatherMap::City do
  let(:city) do
    described_class.new(id: 2_172_797,
                        lat: -16.92,
                        lon: 145.77,
                        name: 'Cairns',
                        temp_k: 300.15)
  end
  let(:other_city) do
    described_class.new(id: 3_186_886,
                        lat: 45.81,
                        lon: 14.98,
                        name: 'Zagreb',
                        temp_k: 20)
  end

  describe '#initialize' do
    it 'correctly initialises values' do
      expect(city.id).to eq(2_172_797)
      expect(city.lat).to eq(-16.92)
      expect(city.lon).to eq(145.77)
      expect(city.name).to eq('Cairns')
      expect(city.temp_k).to eq(300.15)
    end
  end

  describe '#temp' do
    it 'converts temperature to celsius' do
      expect(city.temp).to eq(27.00)
    end
  end

  describe '#<=>' do
    it 'correctly compares two cities by temperature' do
      expect(city < other_city).to eq(false)

      other_city.temp_k = 400

      expect(city < other_city).to eq(true)
    end

    it 'correctly compares two cities with same temperatures but different names' do
      other_city.temp_k = 300.15

      expect(city < other_city).to eq(true)

      other_city.name = 'Bjelovar'

      expect(city < other_city).to eq(false)
    end

    it 'correctly compares two cities with same temperatures and same names' do
      other_city.temp_k = 300.15
      other_city.name = 'Cairns'

      expect(city < other_city).to eq(false)
    end
  end

  describe '#parse' do
    # rubocop:disable RSpec/ExampleLength
    it 'correctly initialises an object from a hash' do
      city_data = {
        'coord' => { 'lat' => 145.77, 'lon' => -16.92 },
        'main' => { 'temp' => 300.15 },
        'id' => 2_172_797,
        'name' => 'Cairns'
      }
      new_from_parse = described_class.parse(city_data)

      expect(new_from_parse.id).to eq(2_172_797)
      expect(city.lat).to eq(-16.92)
      expect(city.lon).to eq(145.77)
      expect(city.name).to eq('Cairns')
      expect(city.temp_k).to eq(300.15)
    end
    # rubocop:enable RSpec/ExampleLength
  end
end

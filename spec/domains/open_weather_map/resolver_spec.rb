RSpec.describe OpenWeatherMap::Resolver do
  it 'when called with a known city name, the assert function returns the correct id' do
    resolver_method = described_class.new.city_id('Ḩeşār-e Sefīd')
    expect(resolver_method).to eq(833)
  end

  it 'when called with an unknown city name, the assert function returns nil' do
    resolver_method = described_class.new.city_id('žnj')
    expect(resolver_method).to eq(nil)
  end
end

RSpec.describe OpenWeatherMap::Resolver do
  it 'returns correct id when called with a known city name' do
    resolver_method = described_class.city_id('Ḩeşār-e Sefīd')

    expect(resolver_method).to eq(833)
  end

  it 'returns nil when called with an unknown city name' do
    resolver_method = described_class.city_id('žnj')

    expect(resolver_method).to be_nil
  end
end

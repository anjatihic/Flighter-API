module OpenWeatherMap
  def self.city(city_name)
    id = Resolver.city_id(city_name)
    return nil if id.nil?

    response = Faraday.get "https://api.openweathermap.org/data/2.5/weather?id=#{id}&appid=a32a4c61d2155b6c3327bc95b5ee7a2f"
    hash_response = JSON.parse(response.body)
    City.parse(hash_response)
  end
end

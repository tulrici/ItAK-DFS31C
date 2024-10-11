const axios = require('axios');

class WeatherService {
  constructor() {
    this.baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
    this.apiKey = ''; // Replace with your actual OpenWeather API key
  }

  /**
   * Fetch weather data from OpenWeather API based on latitude and longitude.
   * @param {number} lat - Latitude of the location.
   * @param {number} lon - Longitude of the location.
   * @returns {Promise<Object>} - Weather data for the given location.
   */
  async getWeatherData(lat, lon) {
    try {
      // Make a request to the OpenWeather API with lat, lon, and your API key
      const response = await axios.get(this.baseUrl, {
        params: {
          lat: lat,
          lon: lon,
          appid: this.apiKey,
          units: 'metric', // Get temperature in Celsius
        },
      });

      // Return the data from OpenWeather if successful
      return response.data;
    } catch (error) {
      console.error('Error fetching weather data:', error.message);
      throw new Error('Unable to fetch weather data');
    }
  }
}

module.exports = WeatherService;

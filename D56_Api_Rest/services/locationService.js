const axios = require('axios');

class LocationService {
  constructor() {
    this.baseUrl = 'https://nominatim.openstreetmap.org';
  }

  /**
   * Fetch location data from Nominatim based on the given query or GPS coordinates.
   * @param {string} query - City name or address (optional).
   * @param {string} lat - Latitude (optional).
   * @param {string} lon - Longitude (optional).
   * @returns {Promise<Object>} - Latitude, Longitude, and other address details.
   */
  async getLocationData(query = null, lat = null, lon = null) {
    try {
      let response;

      // Handle GPS coordinates
      if (lat && lon) {
        response = await axios.get(`${this.baseUrl}/reverse`, {
          params: {
            lat: lat,
            lon: lon,
            format: 'json',
            addressdetails: 1,
          },
        });
      } 
      // Handle city name
      else if (query) {
        response = await axios.get(`${this.baseUrl}/search`, {
          params: {
            q: query,
            format: 'json',
            addressdetails: 1,
            limit: 1, // Limit to one result
          },
        });
      } 
      else {
        throw new Error('No valid query or GPS coordinates provided');
      }

      // Handle results
      if (lat && lon && response.data) {
        return response.data; // Reverse geocoding returns a single object
      } else if (query && response.data.length > 0) {
        return response.data[0]; // Geocoding returns an array
      } else {
        throw new Error('No location data found');
      }
    } catch (error) {
      console.error('Error fetching location data:', error.message);
      throw new Error('Unable to fetch location data');
    }
  }
}

module.exports = LocationService;
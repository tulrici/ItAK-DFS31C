const express = require('express');
const router = express.Router();
const LocationService = require('../services/locationService');
const WeatherService = require('../services/weatherService');
const LocationWeatherDTO = require('../DTO/locationWeatherData');

const locationService = new LocationService();
const weatherService = new WeatherService();

router.get('/locationWeatherData', async (req, res) => {
  const { city, lat, lon } = req.query;

  try {
    const locationData = await locationService.getLocationData(city, lat, lon);
    const weatherData = await weatherService.getWeatherData(locationData.lat, locationData.lon);
    const locationWeatherData = new LocationWeatherDTO(locationData, weatherData);
    return res.json(locationWeatherData);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
require('dotenv').config();
const express = require('express');
const app = express();
const path = require('path');
const port = 3000;
const version = 'V1';

// Serve static files like index.html and styles
app.use(express.static('public'));

// Serve the documentation
app.use('/documentation', (req, res) =>{
    res.sendFile(path.join(__dirname, 'DOC', 'find', 'documentation.md'));
});

// Serve the main page (index.html)
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Import your route files
const jsonRoutes = require('./routes/json');
const xmlRoutes = require('./routes/xml');
const csvRoutes = require('./routes/csv');
const weatherRoutes = require('./routes/weather');
const locationRoutes = require('./routes/location');
const locationWeatherDataRoutes = require('./routes/locationWeatherData');

// Set up routes
app.use(`/APIexercice/${version}`, jsonRoutes);
app.use(`/APIexercice/${version}`, xmlRoutes);
app.use(`/APIexercice/${version}`, csvRoutes);
app.use(`/APIexercice/${version}`, weatherRoutes);
app.use(`/APIexercice/${version}`, locationRoutes);
app.use(`/APIexercice/${version}`, locationWeatherDataRoutes);

app.listen(port, () => {
    console.log(`Exercice app listening on port ${port}`);
});
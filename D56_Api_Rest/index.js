const express = require('express');
const app = express();
const port = 3000;
const version = 'V1';

// Serve static files from the "public" directory
app.use(express.static('public'));

app.get('/', (req, res) => {
    res.send(`
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>API Exercice</title>
            <link rel="stylesheet" href="styles.css">
        </head>
            <body>
                <h1>Bienvenue!</h1>
                <p>Voici les différentes routes disponibles : </p>
                <ul>
                    <li><button onclick="window.location.href='/APIexercice/${version}/json'">Go to JSON Route</button></li>
                    <li><button onclick="window.location.href='/APIexercice/${version}/xml'">Go to XML Route</button></li>
                    <li><button onclick="window.location.href='/APIexercice/${version}/csv'">Go to CSV Route</button></li>
                </ul>
            </body>
        </html>
    `);
});

const jsonRoutes = require('./routes/json');
const xmlRoutes = require('./routes/xml');
const csvRoutes = require('./routes/csv');

app.use(`/APIexercice/${version}`, jsonRoutes);
app.use(`/APIexercice/${version}`, xmlRoutes);
app.use(`/APIexercice/${version}`, csvRoutes);

app.listen(port, () => {
    console.log(`Exercice app listening on port ${port}`);
});
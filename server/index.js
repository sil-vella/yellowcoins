const dotenv = require('dotenv');
dotenv.config();

console.log('CLIENT_ID:', process.env.CLIENT_ID); // Check if CLIENT_ID is loaded
console.log('ADMOB_APP_ID:', process.env.ADMOB_APP_ID); // Check if AdMob ID is loaded

const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { authorize, getAccessToken } = require('./services/google/google_auth');

// This is a test comment

// Import the database connection pool
const db = require('./src/db');

require('./services/cron/get_ecpm_rates');

const userRoutes = require('./routes/userRoutes');
const accountRoutes = require('./routes/account');

const app = express();
const port = process.env.PORT || 3000;

app.use(bodyParser.json());
app.use(cors());

app.use('/api/users', userRoutes);
app.use('/api/account', accountRoutes);

// OAuth2 callback route
app.get('/oauth2callback', async (req, res) => {
  const code = req.query.code;
  if (code) {
    try {
      const token = await getAccessToken(code);
      res.send('Authorization successful! You can close this tab.');
    } catch (err) {
      res.status(500).send('Error retrieving access token');
    }
  } else {
    res.status(400).send('No authorization code found');
  }
});

// Test route to ensure server is running and database connection works
app.get('/test', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT NOW() AS now');
    res.send(`Server is running. Current database time: ${rows[0].now}`);
  } catch (err) {
    console.error('Database connection error:', err);
    res.status(500).send('Error connecting to the database');
  }
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
});

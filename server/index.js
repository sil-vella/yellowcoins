const dotenv = require('dotenv');
dotenv.config();

const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { authorize, getAccessToken } = require('./services/google/google_auth');

require('./services/cron/get_ecpm_rates');

const userRoutes = require('./routes/userRoutes');
const accountRoutes = require('./routes/account');


const app = express();
const port = process.env.PORT || 5000;

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

app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
});

// Test route to ensure server is running
app.get('/test', (req, res) => {
  res.send('Server is running');
});
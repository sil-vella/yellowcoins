// File: server/services/google/google_auth.js
const { google } = require('googleapis');
const { OAuth2Client } = require('google-auth-library');
const fs = require('fs');
const readline = require('readline');
const dotenv = require('dotenv');

dotenv.config();

const CLIENT_ID = process.env.CLIENT_ID;
const CLIENT_SECRET = process.env.CLIENT_SECRET;
const REDIRECT_URI = process.env.REDIRECT_URI;

const oAuth2Client = new OAuth2Client(CLIENT_ID, CLIENT_SECRET, REDIRECT_URI);

console.log('OAuth2Client initialized with CLIENT_ID:', CLIENT_ID);

// Generate a URL to request access from Google's OAuth 2.0 server
function getAuthUrl() {
  console.log('Generating auth URL...');
  const SCOPES = ['https://www.googleapis.com/auth/admob.readonly'];
  const url = oAuth2Client.generateAuthUrl({
    access_type: 'offline',
    scope: SCOPES,
  });
  console.log('Generated auth URL:', url);
  return url;
}

// Get and store new token after prompting for user authorization
function getAccessToken(code) {
  console.log('Getting access token with code:', code);
  return new Promise((resolve, reject) => {
    oAuth2Client.getToken(code, (err, token) => {
      if (err) {
        console.error('Error retrieving access token:', err);
        return reject('Error retrieving access token');
      }
      console.log('Access token retrieved:', token);
      oAuth2Client.setCredentials(token);
      // Store the token to disk for later program executions
      fs.writeFileSync('token.json', JSON.stringify(token));
      console.log('Token saved to token.json');
      resolve(token);
    });
  });
}

// Load or request authorization to call APIs
async function authorize() {
  console.log('Starting authorization process...');
  try {
    const token = JSON.parse(fs.readFileSync('token.json'));
    console.log('Token loaded from file:', token);
    oAuth2Client.setCredentials(token);
    console.log('Authorization successful with token:', token);

    // Automatically refresh token if needed
    await refreshAccessTokenIfNeeded(oAuth2Client);

    return oAuth2Client;
  } catch (err) {
    console.error('Token not found or invalid:', err.message);
    console.log('Authorize this app by visiting this url:', getAuthUrl());
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    });
    return new Promise((resolve) => {
      rl.question('Enter the code from that page here: ', async (code) => {
        rl.close();
        console.log('Code entered by user:', code);
        try {
          const token = await getAccessToken(code);
          console.log('Access token after user authorization:', token);
          resolve(oAuth2Client);
        } catch (err) {
          console.error('Error retrieving access token:', err);
          resolve(null);
        }
      });
    });
  }
}

// Function to refresh the access token if it's close to expiring
async function refreshAccessTokenIfNeeded(oAuth2Client) {
  if (!oAuth2Client.credentials || Date.now() >= oAuth2Client.credentials.expiry_date) {
    console.log('Access token is expired or close to expiring. Refreshing token...');
    try {
      const tokens = await oAuth2Client.refreshAccessToken();
      oAuth2Client.setCredentials(tokens.credentials);
      // Save the new token to file
      fs.writeFileSync('token.json', JSON.stringify(tokens.credentials));
      console.log('New access token retrieved and saved:', tokens.credentials);
    } catch (error) {
      console.error('Error refreshing access token:', error);
    }
  } else {
    console.log('Access token is still valid. No need to refresh.');
  }
}

module.exports = { authorize, getAccessToken, refreshAccessTokenIfNeeded };

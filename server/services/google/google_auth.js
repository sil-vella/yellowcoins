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

// Generate a URL to request access from Google's OAuth 2.0 server
function getAuthUrl() {
  const SCOPES = ['https://www.googleapis.com/auth/admob.readonly'];
  return oAuth2Client.generateAuthUrl({
    access_type: 'offline',
    scope: SCOPES,
  });
}

// Get and store new token after prompting for user authorization
function getAccessToken(code) {
  return new Promise((resolve, reject) => {
    oAuth2Client.getToken(code, (err, token) => {
      if (err) {
        return reject('Error retrieving access token');
      }
      oAuth2Client.setCredentials(token);
      // Store the token to disk for later program executions
      fs.writeFileSync('token.json', JSON.stringify(token));
      resolve(token);
    });
  });
}

// Load or request authorization to call APIs
async function authorize() {
  try {
    const token = JSON.parse(fs.readFileSync('token.json'));
    oAuth2Client.setCredentials(token);
    return oAuth2Client;
  } catch (err) {
    console.log('Authorize this app by visiting this url:', getAuthUrl());
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    });
    return new Promise((resolve) => {
      rl.question('Enter the code from that page here: ', async (code) => {
        rl.close();
        try {
          const token = await getAccessToken(code);
          resolve(oAuth2Client);
        } catch (err) {
          console.error('Error retrieving access token', err);
          resolve(null);
        }
      });
    });
  }
}

module.exports = { authorize, getAccessToken };

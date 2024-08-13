// File: server/services/google/admob.js
const { google } = require('googleapis');
const { authorize } = require('./google_auth');

// Replace with your AdMob account ID
const accountId = 'pub-3883219611722888';

async function listAdUnits() {
  const authClient = await authorize();
  if (!authClient) {
    throw new Error('Authorization failed');
  }
  const admob = google.admob({ version: 'v1', auth: authClient });

  try {
    const response = await admob.accounts.adUnits.list({
      parent: `accounts/${accountId}`,
    });
    console.log('Ad units response:', response.data); // Log the response data
    return response.data;
  } catch (err) {
    console.error('Error listing ad units:', err);
    throw err;
  }
}

module.exports = { listAdUnits };

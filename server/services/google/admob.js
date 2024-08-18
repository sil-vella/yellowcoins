// File: server/services/google/admob.js
const { google } = require('googleapis');
const { authorize } = require('./google_auth');
const dotenv = require('dotenv');

dotenv.config();

const ACCOUNT_ID = process.env.ACCOUNT_ID;

console.log('Initialized AdMob service with account ID:', ACCOUNT_ID);

// Function to list ad units filtered by app ID
async function listAdUnits(appId) {
  console.log('Starting to list ad units...');

  const authClient = await authorize();
  if (!authClient) {
    console.error('Authorization failed');
    throw new Error('Authorization failed');
  }
  console.log('Authorization successful');

  const admob = google.admob({ version: 'v1', auth: authClient });

  try {
    console.log('Sending request to list ad units...');
    const response = await admob.accounts.adUnits.list({
      parent: `accounts/${ACCOUNT_ID}`,
    });

    const adUnits = response.data.adUnits || [];
    if (adUnits.length === 0) {
      console.warn('No ad units found in the account. Please check the account configuration.');
    } else {
      console.log(`Total ad units found: ${adUnits.length}`);
    }

    // Filter ad units by appId if provided
    const filteredAdUnits = appId
      ? adUnits.filter(adUnit => adUnit.appId === appId)
      : adUnits;

    if (filteredAdUnits.length === 0) {
      console.warn(`No ad units found for app ID: ${appId}`);
    } else {
      console.log(`Ad units for app ID ${appId}: (${filteredAdUnits.length})`, filteredAdUnits);
    }

    return filteredAdUnits;
  } catch (err) {
    console.error('Error listing ad units:', err);
    throw err;
  }
}

// Function to generate a network report and calculate the average eCPM for a specific app ID
async function getEcpmRates(appId) {
  console.log(`Starting to generate eCPM rates report for app ID: ${appId}...`);

  const authClient = await authorize();
  if (!authClient) {
    console.error('Authorization failed');
    throw new Error('Authorization failed');
  }
  console.log('Authorization successful');

  const admob = google.admob({ version: 'v1', auth: authClient });

  const today = new Date();
  const year = today.getFullYear();
  const month = today.getMonth() + 1;
  const day = today.getDate();

  try {
    console.log('Sending request to generate network report...');
    const response = await admob.accounts.networkReport.generate({
      parent: `accounts/${ACCOUNT_ID}`,
      requestBody: {
        reportSpec: {
          dateRange: {
            startDate: { year: 2024, month: 1, day: 1 },
            endDate: { year: year, month: month, day: day },
          },
          metrics: ['ESTIMATED_EARNINGS', 'IMPRESSIONS'],
          dimensions: ['AD_UNIT', 'APP'],  // Group by ad unit and app
        },
      },
    });

    console.log('Network report response received:', JSON.stringify(response.data, null, 2));

    let totalEarnings = 0;
    let totalImpressions = 0;

    // Iterate through the response and aggregate earnings and impressions for the specified appId
    response.data.forEach(item => {
      if (item.row) {
        const rowAppId = item.row.dimensionValues.APP.value;
        if (rowAppId === appId) {
          const impressions = parseFloat(item.row.metricValues.IMPRESSIONS.integerValue);
          const estimatedEarnings = parseFloat(item.row.metricValues.ESTIMATED_EARNINGS.microsValue) / 1000000;

          totalEarnings += estimatedEarnings;
          totalImpressions += impressions;
        }
      }
    });

    if (totalImpressions === 0) {
      throw new Error(`No impressions found for app ID: ${appId}`);
    }

    const averageEcpm = (totalEarnings / totalImpressions) * 1000; // Calculate the average eCPM
    console.log(`Calculated average eCPM for app ID ${appId}: ${averageEcpm}`);

    return averageEcpm;
  } catch (err) {
    console.error('Error generating network report:', err);

    if (err.response) {
      console.error('Response data:', JSON.stringify(err.response.data, null, 2));
      console.error('Response status:', err.response.status);
      console.error('Response headers:', err.response.headers);
    }

    throw err;
  }
}

module.exports = { listAdUnits, getEcpmRates };

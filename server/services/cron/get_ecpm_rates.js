const cron = require('node-cron');
const { getEcpmRates } = require('../../services/google/admob'); // Import the getEcpmRates function
const db = require('../../src/db'); // Ensure this path points to the DatabaseHelper

const APP_ID = process.env.ADMOB_APP_ID; // Get the App ID from environment variables

// Function to fetch eCPM rates and update the database with the average eCPM
async function updateEcpmRates() {
  try {
    if (!APP_ID) {
      throw new Error('App ID is not defined in environment variables.');
    }

    console.log(`Fetching average eCPM for app ID: ${APP_ID}...`);
    const averageEcpm = await getEcpmRates(APP_ID); // Fetch the average eCPM for the app
    console.log(`Average eCPM for app ID ${APP_ID}: ${averageEcpm}`);

    const currentDate = new Date().toISOString();

    // Update the database with the average eCPM
    await db.upsertAverageEcpmRate(averageEcpm, currentDate);
    console.log(`Average eCPM updated successfully to ${averageEcpm}.`);
  } catch (error) {
    console.error('Error fetching eCPM rates:', error);
  }
}

// Uncomment this if you want to run the cron job automatically on a schedule
// cron.schedule('0 0 * * 1', () => {
//   console.log('Running scheduled task to update eCPM rates...');
//   updateEcpmRates();
// });

// Run the updateEcpmRates function immediately
updateEcpmRates().then(() => {
  console.log('Manual run of updateEcpmRates completed.');
});

const express = require('express');
const db = require('../src/db'); // MySQL-based database helper
const { createStripeAccount, createAccountLink } = require('../services/stripe/create_account');
const router = express.Router();
const dotenv = require('dotenv');

dotenv.config();

// Handle Stripe reauth
router.get('/stripe-reauth', (req, res) => {
  res.send('Stripe reauthentication endpoint');
});

// Handle Stripe account completion
router.get('/stripe-account-complete', (req, res) => {
  res.send('Stripe account completion endpoint');
});

// Sign up route
router.post('/signup', async (req, res) => {
  const { email, password, country } = req.body;

  if (!email || !password || !country) {
    return res.status(400).json({ error: 'Email, password, and country are required' });
  }

  try {
    const user = await db.getUserByEmail(email); // Await the promise returned by the database call
    if (user) {
      return res.status(400).json({ error: 'Email already exists' });
    }

    const userId = await db.insertUser(email, password, null); // Insert user and await the result
    const accountId = await createStripeAccount(userId, email, country);
    const accountLinkUrl = await createAccountLink(accountId);

    await db.updateUserStripeAccountId(userId, accountId); // Update Stripe account ID

    res.status(201).json({ message: 'Account created successfully', userId, accountLinkUrl });
  } catch (err) {
    console.error('Error during signup:', err);
    res.status(500).json({ error: 'Failed to create account' });
  }
});

// Login route
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    const user = await db.getUserByEmail(email); // Await the promise returned by the database call
    if (!user || user.password !== password) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }

    // Get the AdMob rewarded ad unit ID from environment variables
    const rewardAdId = process.env.ADMOB_REWARDED_AD_UNIT_ID;

    // Fetch the eCPM rate from the database
    const ecpmRate = await db.getAverageEcpmRate(); // Await the promise to get the eCPM rate

    // Return user data, AdMob rewarded ad unit ID, and eCPM rate on successful login
    res.status(200).json({
      message: 'Login successful',
      userId: user.id,
      email: user.email,
      stripeAccountId: user.stripeAccountId,
      coins: user.coins,
      earnings: user.earnings,
      rewardedAdUnitId: rewardAdId,
      ecpmRate: ecpmRate, // Include the eCPM rate
    });
  } catch (err) {
    console.error('Error during login:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

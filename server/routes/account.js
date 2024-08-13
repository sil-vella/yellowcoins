// File: server/routes/account.js

const express = require('express');
const { createStripeAccount, createAccountLink, createLoginLink, triggerPayment } = require('../services/stripe/create_account');
const db = require('../services/database');
const { listAdUnits, generateNetworkReport } = require('../services/google/admob');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const router = express.Router();

// Create a Stripe account
router.post('/create-account', async (req, res) => {
  const { userId, email } = req.body;
  try {
    const accountId = await createStripeAccount(userId, email);
    const accountLinkUrl = await createAccountLink(accountId);
    res.json({ accountLinkUrl });
  } catch (err) {
    res.status(500).send('Error creating Stripe account');
  }
});

// Create a login link
router.post('/create-login-link', (req, res) => {
  const { userId } = req.body;
  db.getUserById(userId, async (err, user) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: 'Database error' });
    }
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    try {
      const account = await stripe.accounts.retrieve(user.stripeAccountId);
      if (account.requirements.disabled_reason) {
        const accountLinkUrl = await createAccountLink(user.stripeAccountId);
        console.log('Onboarding required, returning account link:', accountLinkUrl); // Log the account link
        return res.status(400).json({
          error: 'Account onboarding not completed',
          accountLinkUrl: accountLinkUrl,
        });
      }

      const loginLinkUrl = await createLoginLink(user.stripeAccountId);
      res.json({ loginLinkUrl });
    } catch (err) {
      console.error('Error creating login link:', err);
      res.status(500).json({ error: 'Error creating login link' });
    }
  });
});

// Trigger payment
router.post('/trigger-payment', async (req, res) => {
  const { accountId, amount } = req.body;
  try {
    const payout = await triggerPayment(accountId, amount);
    res.json({ payout });
  } catch (err) {
    res.status(500).send('Error triggering payment');
  }
});

// Log ad view
router.post('/log-ad-view', async (req, res) => {
  const { userId, adType, rewardAmount, rewardType } = req.body;

  try {
    db.logAdView(userId, adType, 0, rewardAmount, rewardType, async (err) => {
      if (err) {
        console.error('Database error:', err);
        return res.status(500).json({ error: 'Database error' });
      }
      res.status(200).json({ message: 'Ad view logged successfully' });
    });
  } catch (err) {
    console.error('Error logging ad view:', err);
    res.status(500).json({ error: 'Error logging ad view' });
  }
});

// List ad units
router.get('/list-ad-units', async (req, res) => {
  try {
    const adUnits = await listAdUnits();
    res.json(adUnits);
  } catch (err) {
    console.error('Error listing ad units:', err); // Log the full error details
    res.status(500).json({ error: `Error listing ad units: ${err.message}` });
  }
});

// Generate Network Report for an Ad Unit
router.post('/generate-network-report', async (req, res) => {
  const { adUnitId } = req.body;

  try {
    const report = await generateNetworkReport(adUnitId);
    res.json(report);
  } catch (err) {
    console.error('Error generating network report:', err.message);
    res.status(500).send('Error generating network report');
  }
});

module.exports = router;

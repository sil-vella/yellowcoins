// File: server/routes/account.js

const express = require('express');
const { createStripeAccount, createAccountLink, createLoginLink, triggerPayment } = require('../services/stripe/create_account');
const db = require('../services/database');
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
          accountLinkUrl: accountLinkUrl
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
    const earnings = calculateEarnings(rewardAmount); // Implement this function based on your eCPM

    db.logAdView(userId, adType, earnings, rewardAmount, rewardType, async (err) => {
      if (err) {
        console.error('Database error:', err);
        return res.status(500).json({ error: 'Database error' });
      }

      try {
        // Check if user meets the payout threshold
        await triggerPayout(userId);
        res.status(200).json({ message: 'Ad view logged and payout checked' });
      } catch (error) {
        console.error('Error triggering payout:', error);
        res.status(500).json({ error: 'Error triggering payout' });
      }
    });
  } catch (err) {
    console.error('Error logging ad view:', err);
    res.status(500).json({ error: 'Error logging ad view' });
  }
});

function calculateEarnings(rewardAmount) {
  const eCPM = 1.0; // Example eCPM, replace with actual value
  const earningsPerView = (eCPM / 1000); // Earnings per view in dollars
  return Math.round(earningsPerView * rewardAmount * 100); // Convert to cents
}

module.exports = router;

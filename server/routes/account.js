const express = require('express');
const { createStripeAccount, createAccountLink, createLoginLink, triggerPayment } = require('../services/stripe/create_account');
const db = require('../src/db');  // Ensure this points to the MySQL-based db.js
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
    console.error('Error creating Stripe account:', err);
    res.status(500).send('Error creating Stripe account');
  }
});

// Create a login link
router.post('/create-login-link', async (req, res) => {
  const { userId } = req.body;
  try {
    const user = await db.getUserById(userId);  // Use async/await with the MySQL helper method
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

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

// Trigger payment
router.post('/trigger-payment', async (req, res) => {
  const { accountId, amount } = req.body;
  try {
    const payout = await triggerPayment(accountId, amount);
    res.json({ payout });
  } catch (err) {
    console.error('Error triggering payment:', err);
    res.status(500).send('Error triggering payment');
  }
});

// Update user coins and earnings
router.post('/update-coins-earnings', async (req, res) => {
  const { userId, coins, earnings } = req.body;

  if (!userId || coins == null || earnings == null) {
    return res.status(400).json({ error: 'UserId, coins, and earnings are required' });
  }

  try {
    await db.updateUserCoinsAndEarnings(userId, coins, earnings);  // Use async/await
    res.status(200).json({ message: 'Coins and earnings updated successfully' });
  } catch (err) {
    console.error('Error updating coins and earnings:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

const express = require('express');
const { createStripeAccount, createAccountLink, createLoginLink, triggerPayment } = require('../services/stripe/create_account');
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
router.post('/create-login-link', async (req, res) => {
  const { accountId } = req.body;
  try {
    const loginLinkUrl = await createLoginLink(accountId);
    res.json({ loginLinkUrl });
  } catch (err) {
    res.status(500).send('Error creating login link');
  }
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

module.exports = router;

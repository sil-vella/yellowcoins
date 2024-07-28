const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const db = require('../database');

async function createStripeAccount(userId, email) {
  try {
    const account = await stripe.accounts.create({
      type: 'express',
      country: 'US',
      email: email,
      capabilities: {
        card_payments: { requested: true },
        transfers: { requested: true },
      },
    });

    await db.updateUserStripeAccountId(userId, account.id);
    return account.id;
  } catch (err) {
    console.error('Error creating Stripe account:', err);
    throw err;
  }
}

async function createAccountLink(accountId) {
  try {
    const accountLink = await stripe.accountLinks.create({
      account: accountId,
      refresh_url: 'http://localhost:5000/stripe-reauth', // Update with your valid URL
      return_url: 'http://localhost:5000/stripe-account-complete', // Update with your valid URL
      type: 'account_onboarding',
    });
    return accountLink.url;
  } catch (err) {
    console.error('Error creating account link:', err);
    throw err;
  }
}

async function createLoginLink(accountId) {
  try {
    const loginLink = await stripe.accounts.createLoginLink(accountId);
    return loginLink.url;
  } catch (err) {
    console.error('Error creating login link:', err);
    throw err;
  }
}

module.exports = { createStripeAccount, createAccountLink, createLoginLink };

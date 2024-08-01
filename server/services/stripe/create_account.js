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
      refresh_url: 'http://192.168.178.80:5000/stripe-reauth', // Replace with your server's IP address and endpoint
      return_url: 'http://192.168.178.80:5000/stripe-account-complete', // Replace with your server's IP address and endpoint
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

async function triggerPayment(accountId, amount) {
  try {
    const payout = await stripe.payouts.create({
      amount: amount, // Amount in cents
      currency: 'usd',
    }, {
      stripeAccount: accountId,
    });
    return payout;
  } catch (err) {
    console.error('Error triggering payment:', err);
    throw err;
  }
}

module.exports = { createStripeAccount, createAccountLink, createLoginLink, triggerPayment };

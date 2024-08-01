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
      refresh_url: 'yellowcoinsapp://stripe-reauth', // Custom scheme for your app
      return_url: 'yellowcoinsapp://stripe-account-complete', // Custom scheme for your app
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

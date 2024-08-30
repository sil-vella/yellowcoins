const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const db = require('../../src/db'); // Make sure this path correctly points to your DatabaseHelper

async function createStripeAccount(userId, email) {
  try {
    const account = await stripe.accounts.create({
      type: 'express',
      email: email,
      business_type: 'individual', // Specify the business type
      capabilities: {
        card_payments: { requested: true },
        transfers: { requested: true },
      },
    });

    // Update the database with the new Stripe account ID
    await db.updateUserStripeAccountId(userId, account.id);
    return account.id;
  } catch (err) {
    console.error('Error creating Stripe account:', err);
    throw err; // Rethrow the error to be handled by the caller if necessary
  }
}

async function createAccountLink(accountId) {
  try {
    const accountLink = await stripe.accountLinks.create({
      account: accountId,
      refresh_url: process.env.STRIPE_REFRESH_URL, // Use environment variable to manage URL
      return_url: process.env.STRIPE_RETURN_URL, // Use environment variable to manage URL
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
      amount: amount * 100, // Ensure the amount is in cents
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

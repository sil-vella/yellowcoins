const express = require('express');
const db = require('../services/database');
const { createStripeAccount, createAccountLink, createLoginLink } = require('../services/stripe/create_account');
const router = express.Router();

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
  const { email, password } = req.body;

  // Basic validation
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    // Check if email already exists
    db.getUserByEmail(email, (err, user) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      if (user) {
        return res.status(400).json({ error: 'Email already exists' });
      }

      // Insert new user
      db.insertUser(email, password, async (err, userId) => {
        if (err) {
          return res.status(500).json({ error: 'Failed to create account' });
        }

        // Create Stripe account
        try {
          const accountId = await createStripeAccount(userId, email);
          const accountLinkUrl = await createAccountLink(accountId);

          res.status(201).json({ message: 'Account created successfully', userId, accountLinkUrl });
        } catch (stripeErr) {
          return res.status(500).json({ error: 'Failed to create Stripe account' });
        }
      });
    });
  } catch (err) {
    res.status(500).json({ error: 'Failed to create account' });
  }
});

// Login route
router.post('/login', async (req, res) => {
  console.log('Received login request');
  const { email, password } = req.body;
  console.log('Email:', email, 'Password:', password);

  // Basic validation
  if (!email || !password) {
    console.log('Email and password are required');
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    // Check if user exists and password matches
    db.getUserByEmail(email, (err, user) => {
      if (err) {
        console.log('Database error:', err);
        return res.status(500).json({ error: 'Database error' });
      }
      if (!user) {
        console.log('User not found');
        return res.status(400).json({ error: 'Invalid email or password' });
      }
      if (user.password !== password) {
        console.log('Invalid password');
        return res.status(400).json({ error: 'Invalid email or password' });
      }

      console.log('Login successful for userId:', user.id);
      res.status(200).json({ message: 'Login successful', userId: user.id });
    });
  } catch (err) {
    console.log('Database error:', err);
    res.status(500).json({ error: 'Database error' });
  }
});

module.exports = router;

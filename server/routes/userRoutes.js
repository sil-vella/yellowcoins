const express = require('express');
const db = require('../services/database');
const { createStripeAccount, createAccountLink } = require('../services/stripe/create_account');
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
  const { email, password, country } = req.body;

  if (!email || !password || !country) {
    return res.status(400).json({ error: 'Email, password, and country are required' });
  }

  try {
    db.getUserByEmail(email, async (err, user) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      if (user) {
        return res.status(400).json({ error: 'Email already exists' });
      }

      db.insertUser(email, password, null, async (err, userId) => {
        if (err) {
          return res.status(500).json({ error: 'Failed to create account' });
        }

        try {
          const accountId = await createStripeAccount(userId, email, country);
          const accountLinkUrl = await createAccountLink(accountId);

          db.updateUserStripeAccountId(userId, accountId, (err) => {
            if (err) {
              return res.status(500).json({ error: 'Failed to update Stripe account ID' });
            }
            res.status(201).json({ message: 'Account created successfully', userId, accountLinkUrl });
          });
        } catch (stripeErr) {
          console.error('Error creating account link:', stripeErr);
          return res.status(500).json({ error: 'Failed to create Stripe account' });
        }
      });
    });
  } catch (err) {
    console.error('Error during signup:', err);
    res.status(500).json({ error: 'Failed to create account' });
  }
});

router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    db.getUserByEmail(email, (err, user) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      if (!user) {
        return res.status(400).json({ error: 'Invalid email or password' });
      }
      if (user.password !== password) {
        return res.status(400).json({ error: 'Invalid email or password' });
      }

      // Return user data on successful login
      res.status(200).json({
        message: 'Login successful',
        userId: user.id,
        email: user.email,
        stripeAccountId: user.stripeAccountId,
        earnings: user.earnings // Ensure earnings are included
      });
    });
  } catch (err) {
    res.status(500).json({ error: 'Database error' });
  }
});


module.exports = router;

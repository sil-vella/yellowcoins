const express = require('express');
const db = require('../services/database');
const router = express.Router();

router.post('/signup', (req, res) => {
  const { name, email, password, paypalAccount } = req.body;

  // Basic validation
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  // Check if email already exists
  db.getUserByEmail(email, (err, user) => {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }

    if (user) {
      return res.status(400).json({ error: 'Email already exists' });
    }

    // Insert new user
    db.insertUser(name, email, password, paypalAccount, (err, userId) => {
      if (err) {
        return res.status(500).json({ error: 'Failed to create account' });
      }
      res.status(201).json({ message: 'Account created successfully', userId });
    });
  });
});

module.exports = router;

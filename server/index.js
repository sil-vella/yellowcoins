// File: server/index.js
const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const admin = require('firebase-admin');
const serviceAccount = require('./path/to/serviceAccountKey.json'); // Replace with the path to your Firebase service account key

// Firebase initialization
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://<your-database-name>.firebaseio.com" // Replace with your database URL
});

// SQLite initialization
const db = new sqlite3.Database('./local.db', (err) => {
  if (err) {
    console.error(err.message);
  }
  console.log('Connected to the local SQLite database.');
});

const app = express();
app.use(express.json());

// Example endpoint to create a user
app.post('/create_account', async (req, res) => {
  const { name, email, password } = req.body;
  try {
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
    });
    const userId = userRecord.uid;
    const sql = 'INSERT INTO users (id, name, email, password) VALUES (?, ?, ?, ?)';
    db.run(sql, [userId, name, email, password], function (err) {
      if (err) {
        return res.status(400).json({ error: err.message });
      }
      res.status(201).send('Account created successfully');
    });
  } catch (error) {
    res.status(500).send(error.message);
  }
});

// Example endpoint to connect PayPal
app.post('/connect_paypal', (req, res) => {
  const { userId, paypalAccount } = req.body;
  try {
    const sql = 'UPDATE users SET paypalAccount = ? WHERE id = ?';
    db.run(sql, [paypalAccount, userId], function (err) {
      if (err) {
        return res.status(400).json({ error: err.message });
      }
      res.status(200).send('PayPal account connected successfully');
    });
  } catch (error) {
    res.status(500).send(error.message);
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

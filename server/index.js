// File: server/index.js
const express = require('express');
const admin = require('firebase-admin');
const serviceAccount = require('./path/to/serviceAccountKey.json'); // Replace with the path to your Firebase service account key

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://<your-database-name>.firebaseio.com" // Replace with your database URL
});

const app = express();
app.use(express.json());

// Example endpoint to create a user
app.post('/create_account', async (req, res) => {
  const user = req.body;
  try {
    const userRecord = await admin.auth().createUser({
      email: user.email,
      password: user.password,
    });
    await admin.firestore().collection('users').doc(userRecord.uid).set(user);
    res.status(201).send('Account created successfully');
  } catch (error) {
    res.status(500).send(error.message);
  }
});

// Example endpoint to connect PayPal
app.post('/connect_paypal', async (req, res) => {
  const { userId, paypalAccount } = req.body;
  try {
    await admin.firestore().collection('users').doc(userId).update({
      paypalAccount,
    });
    res.status(200).send('PayPal account connected successfully');
  } catch (error) {
    res.status(500).send(error.message);
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

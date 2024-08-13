// File: server/services/database.js

const sqlite3 = require('sqlite3').verbose();

class DatabaseHelper {
  constructor() {
    this.db = new sqlite3.Database('./local.db', (err) => {
      if (err) {
        console.error('Error opening database:', err.message);
      } else {
        this.initialize();
      }
    });
  }

  initialize() {
    const userTable = `
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        stripeAccountId TEXT,
        coins INTEGER DEFAULT 0,
        ecpmRate REAL DEFAULT 0.0
      )
    `;
    this.db.run(userTable, (err) => {
      if (err) {
        console.error('Error creating users table:', err.message);
      }
    });

    const adViewTable = `
      CREATE TABLE IF NOT EXISTS ad_views (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        adType TEXT NOT NULL,
        earnings INTEGER NOT NULL,
        rewardAmount INTEGER NOT NULL,
        rewardType TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    `;
    this.db.run(adViewTable, (err) => {
      if (err) {
        console.error('Error creating ad_views table:', err.message);
      }
    });
  }

  insertUser(email, password, stripeAccountId, callback) {
    const query = `INSERT INTO users (email, password, stripeAccountId) VALUES (?, ?, ?)`;
    this.db.run(query, [email, password, stripeAccountId], function (err) {
      if (typeof callback === 'function') {
        callback(err, this ? this.lastID : null);
      }
    });
  }

  getUserByEmail(email, callback) {
    const query = `SELECT * FROM users WHERE email = ?`;
    this.db.get(query, [email], (err, row) => {
      if (typeof callback === 'function') {
        callback(err, row);
      }
    });
  }

  getUserById(id, callback) {
    const query = `SELECT * FROM users WHERE id = ?`;
    this.db.get(query, [id], (err, row) => {
      if (typeof callback === 'function') {
        callback(err, row);
      }
    });
  }

  updateUserStripeAccountId(userId, stripeAccountId, callback) {
    const query = `UPDATE users SET stripeAccountId = ? WHERE id = ?`;
    this.db.run(query, [stripeAccountId, userId], function (err) {
      if (typeof callback === 'function') {
        callback(err);
      }
    });
  }

  logAdView(userId, adType, earnings, rewardAmount, rewardType, callback) {
    const query = `
      INSERT INTO ad_views (userId, adType, earnings, rewardAmount, rewardType)
      VALUES (?, ?, ?, ?, ?)
    `;
    this.db.run(query, [userId, adType, earnings, rewardAmount, rewardType], function (err) {
      if (err) {
        return callback(err);
      }

      // Update user's coins based on ad type
      const updateCoinsQuery = `
        UPDATE users
        SET coins = coins + ?
        WHERE id = ?
      `;
      // Use an arrow function here to preserve the 'this' context
      this.db.run(updateCoinsQuery, [rewardAmount, userId], (err) => {
        callback(err);
      });
    }.bind(this)); // Bind 'this' to preserve context
  }

  updateUserEarnings(userId, earnings, callback) {
    const query = `
      UPDATE users
      SET earnings = ?
      WHERE id = ?
    `;
    this.db.run(query, [earnings, userId], function (err) {
      if (typeof callback === 'function') {
        callback(err);
      }
    });
  }
}

module.exports = new DatabaseHelper();

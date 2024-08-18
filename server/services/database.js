const sqlite3 = require('sqlite3').verbose();
const path = require('path');

class DatabaseHelper {
  constructor() {
    const dbPath = path.resolve(__dirname, '../../local.db');
    this.db = new sqlite3.Database(dbPath, (err) => {
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
        earnings REAL DEFAULT 0.0
      )
    `;
    this.db.run(userTable, (err) => {
      if (err) {
        console.error('Error creating users table:', err.message);
      }
    });

    const ecpmTable = `
      CREATE TABLE IF NOT EXISTS ecpm_rates (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        averageEcpm REAL NOT NULL,
        lastFetchDate TEXT NOT NULL
      )
    `;
    this.db.run(ecpmTable, (err) => {
      if (err) {
        console.error('Error creating ecpm_rates table:', err.message);
      }
    });
  }

  upsertAverageEcpmRate(averageEcpm, lastFetchDate, callback) {
    const query = `
      INSERT INTO ecpm_rates (id, averageEcpm, lastFetchDate)
      VALUES (1, ?, ?)
      ON CONFLICT(id)
      DO UPDATE SET averageEcpm = excluded.averageEcpm, lastFetchDate = excluded.lastFetchDate
    `;
    this.db.run(query, [averageEcpm, lastFetchDate], function (err) {
      if (typeof callback === 'function') {
        callback(err);
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

  updateUserCoinsAndEarnings(userId, coins, earnings, callback) {
    const query = `
      UPDATE users
      SET coins = ?, earnings = ?
      WHERE id = ?
    `;
    this.db.run(query, [coins, earnings, userId], function (err) {
      if (typeof callback === 'function') {
        callback(err);
      }
    });
  }

  getAverageEcpmRate(callback) {
    const query = `SELECT averageEcpm FROM ecpm_rates WHERE id = 1`;
    this.db.get(query, [], (err, row) => {
      if (err) {
        return callback(err, null);
      }
      callback(null, row ? row.averageEcpm : null);
    });
  }
}

module.exports = new DatabaseHelper();

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
        stripeAccountId TEXT
      )
    `;
    this.db.run(userTable, (err) => {
      if (err) {
        console.error('Error creating users table:', err.message);
      }
    });
  }

  insertUser(email, password, callback) {
    const query = `INSERT INTO users (email, password) VALUES (?, ?)`;
    this.db.run(query, [email, password], function (err) {
      if (callback && typeof callback === 'function') {
        callback(err, this ? this.lastID : null);
      }
    });
  }

  getUserByEmail(email, callback) {
    const query = `SELECT * FROM users WHERE email = ?`;
    this.db.get(query, [email], (err, row) => {
      if (callback && typeof callback === 'function') {
        callback(err, row);
      }
    });
  }

  updateUserStripeAccountId(userId, stripeAccountId, callback) {
    const query = `UPDATE users SET stripeAccountId = ? WHERE id = ?`;
    this.db.run(query, [stripeAccountId, userId], function (err) {
      if (callback && typeof callback === 'function') {
        callback(err, this ? this.changes : null);
      }
    });
  }
}

module.exports = new DatabaseHelper();

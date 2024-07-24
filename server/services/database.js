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
        name TEXT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        paypalAccount TEXT
      )
    `;
    this.db.run(userTable, (err) => {
      if (err) {
        console.error('Error creating users table:', err.message);
      }
    });
  }

  insertUser(name, email, password, paypalAccount, callback) {
    const query = `INSERT INTO users (name, email, password, paypalAccount) VALUES (?, ?, ?, ?)`;
    this.db.run(query, [name, email, password, paypalAccount], function (err) {
      callback(err, this ? this.lastID : null);
    });
  }
}

module.exports = new DatabaseHelper();

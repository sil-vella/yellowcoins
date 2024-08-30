const mysql = require('mysql2/promise');

// Create a MySQL connection pool using environment variables
const pool = mysql.createPool({
  host: 'db', // Service name defined in docker-compose.yml
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD,
  database: process.env.MYSQL_DATABASE,
});

// Helper class for MySQL operations
class DatabaseHelper {
  constructor() {
    // Initialize database tables if necessary (e.g., when first connecting)
    this.initialize();
  }

  async initialize() {
    try {
      // SQL queries to create tables if they don't exist
      const userTable = `
        CREATE TABLE IF NOT EXISTS users (
          id INT AUTO_INCREMENT PRIMARY KEY,
          email VARCHAR(255) NOT NULL UNIQUE,
          password VARCHAR(255) NOT NULL,
          stripeAccountId VARCHAR(255),
          coins INT DEFAULT 0,
          earnings DECIMAL(10, 2) DEFAULT 0.0
        )
      `;
      const ecpmTable = `
        CREATE TABLE IF NOT EXISTS ecpm_rates (
          id INT PRIMARY KEY CHECK (id = 1),
          averageEcpm DECIMAL(10, 2) NOT NULL,
          lastFetchDate DATETIME NOT NULL
        )
      `;
      await pool.query(userTable);
      await pool.query(ecpmTable);
    } catch (err) {
      console.error('Error initializing database:', err.message);
    }
  }

  async upsertAverageEcpmRate(averageEcpm, lastFetchDate) {
    try {
      const query = `
        INSERT INTO ecpm_rates (id, averageEcpm, lastFetchDate)
        VALUES (1, ?, ?)
        ON DUPLICATE KEY UPDATE averageEcpm = VALUES(averageEcpm), lastFetchDate = VALUES(lastFetchDate)
      `;
      await pool.query(query, [averageEcpm, lastFetchDate]);
    } catch (err) {
      console.error('Error upserting average ECPM rate:', err.message);
    }
  }

  async insertUser(email, password, stripeAccountId) {
    try {
      const query = `INSERT INTO users (email, password, stripeAccountId) VALUES (?, ?, ?)`;
      const [result] = await pool.query(query, [email, password, stripeAccountId]);
      return result.insertId; // Return the ID of the newly inserted user
    } catch (err) {
      console.error('Error inserting user:', err.message);
      throw err;
    }
  }

  async getUserByEmail(email) {
    try {
      const query = `SELECT * FROM users WHERE email = ?`;
      const [rows] = await pool.query(query, [email]);
      return rows[0]; // Return the first (and should be only) matching user
    } catch (err) {
      console.error('Error fetching user by email:', err.message);
      throw err;
    }
  }

  async getUserById(id) {
    try {
      const query = `SELECT * FROM users WHERE id = ?`;
      const [rows] = await pool.query(query, [id]);
      return rows[0];
    } catch (err) {
      console.error('Error fetching user by ID:', err.message);
      throw err;
    }
  }

  async updateUserStripeAccountId(userId, stripeAccountId) {
    try {
      const query = `UPDATE users SET stripeAccountId = ? WHERE id = ?`;
      await pool.query(query, [stripeAccountId, userId]);
    } catch (err) {
      console.error('Error updating user Stripe account ID:', err.message);
      throw err;
    }
  }

  async updateUserCoinsAndEarnings(userId, coins, earnings) {
    try {
      const query = `
        UPDATE users
        SET coins = ?, earnings = ?
        WHERE id = ?
      `;
      await pool.query(query, [coins, earnings, userId]);
    } catch (err) {
      console.error('Error updating user coins and earnings:', err.message);
      throw err;
    }
  }

  async getAverageEcpmRate() {
    try {
      const query = `SELECT averageEcpm FROM ecpm_rates WHERE id = 1`;
      const [rows] = await pool.query(query);
      return rows.length ? rows[0].averageEcpm : null;
    } catch (err) {
      console.error('Error fetching average ECPM rate:', err.message);
      throw err;
    }
  }
}

module.exports = new DatabaseHelper();

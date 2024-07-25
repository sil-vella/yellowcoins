const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors'); // Add CORS middleware
const userRoutes = require('./routes/userRoutes');
const app = express();
const port = 5000;

// Middleware
app.use(bodyParser.json());
app.use(cors()); // Use CORS middleware

// Routes
app.use('/api', userRoutes);

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

const express = require("express");
const bodyParser = require("body-parser");
const UserRoute = require("./routes/user.router");
const cors = require("cors");

const app = express();

// Middleware
app.use(bodyParser.json());

// Allow all origins (for development)
app.use(cors());

// Mount your routes under /auth
app.use("/auth", UserRoute);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ status: false, error: err.message });
});

module.exports = app;

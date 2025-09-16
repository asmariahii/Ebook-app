const express = require("express");
const bodyParser = require("body-parser");
const UserRoute = require("./routes/user.router");

const app = express();

// Middleware
app.use(bodyParser.json());

// Routes
app.use("/", UserRoute);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ status: false, error: err.message });
});

module.exports = app;

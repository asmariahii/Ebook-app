const express = require("express");
const router = express.Router();
const bookController = require("../controller/book.controller");

// Add new book
router.post("/add", bookController.addBook);

// Get all books
router.get("/", bookController.getBooks);

// Get trending books
router.get("/trending", bookController.getTrending);

module.exports = router;

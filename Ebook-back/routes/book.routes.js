const express = require("express");
const router = express.Router();
const bookController = require("../controller/book.controller");

// Specific routes first
router.post("/add", bookController.addBook);
router.get("/", bookController.getBooks);
router.get("/trending", bookController.getTrending);
router.get("/search", bookController.searchBooks);
router.get("/analytics", bookController.getAnalytics); 

// Dynamic routes last
router.get("/:id", bookController.getBookById);
router.delete("/:id", bookController.deleteBook);

module.exports = router;
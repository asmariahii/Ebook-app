const BookServices = require("../services/book.service");
const Book = require("../model/book.model"); 

// Add new book
exports.addBook = async (req, res, next) => {
    try {
        const { title, author, description, cover, file, isTrending } = req.body;

        if (!title || !author || !description || !cover || !file) {
            return res.status(400).json({ status: false, error: "All fields are required" });
        }

        const book = await BookServices.addBook({ title, author, description, cover, file, isTrending });
        res.status(201).json({ status: true, success: "Book added successfully", data: book });
    } catch (err) {
        console.error(err);
        res.status(500).json({ status: false, error: err.message });
    }
};

// Get all books
exports.getBooks = async (req, res, next) => {
    try {
        const books = await BookServices.getAllBooks();
        res.status(200).json({ status: true, data: books });
    } catch (err) {
        console.error(err);
        res.status(500).json({ status: false, error: err.message });
    }
};

// Get trending books
exports.getTrending = async (req, res, next) => {
    try {
        const trendingBooks = await BookServices.getTrendingBooks();
        res.status(200).json({ status: true, data: trendingBooks });
    } catch (err) {
        console.error(err);
        res.status(500).json({ status: false, error: err.message });
    }
};





// ADD THIS: Get book by ID
exports.getBookById = async (req, res) => {
  try {
    const bookId = req.params.id;
    console.log('📖 GET BOOK BY ID:', bookId);
    
    const book = await Book.findById(bookId);
    
    if (!book) {
      console.log('❌ Book not found:', bookId);
      return res.status(404).json({ 
        status: false, 
        error: "Book not found" 
      });
    }

    console.log('✅ Book found:', book.title);
    res.status(200).json({ 
      status: true, 
      data: book 
    });
  } catch (err) {
    console.error('❌ Get book by ID error:', err);
    res.status(500).json({ 
      status: false, 
      error: err.message 
    });
  }
};

exports.searchBooks = async (req, res) => {
  try {
    const { q } = req.query;
    
    console.log("🔍 Search query received:", q);
    
    if (!q || typeof q !== 'string' || q.trim() === '') {
      console.log("❌ Empty search query");
      return res.status(400).json({ 
        status: false, 
        error: "Search query is required" 
      });
    }

    const searchTerm = q.trim();
    console.log("🔍 Searching for:", searchTerm);

    const searchQuery = {
      $or: [
        { title: { $regex: searchTerm, $options: 'i' } },
        { author: { $regex: searchTerm, $options: 'i' } }
      ]
    };

    console.log("🔍 MongoDB query:", JSON.stringify(searchQuery));

    const books = await Book.find(searchQuery)
      .select('-__v')
      .limit(50)
      .sort({ createdAt: -1 });

    console.log(`✅ Found ${books.length} books for query: "${searchTerm}"`);

    res.json({
      status: true,
      data: books,
      count: books.length,
      query: searchTerm
    });

  } catch (error) {
    console.error("❌ Search error details:", error);
    res.status(500).json({ 
      status: false, 
      error: "Search failed",
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};
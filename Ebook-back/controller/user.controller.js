const { UserServices } = require('../services/user.service');
const Book = require("../model/book.model");
const User = require("../model/user.model"); // ADD THIS LINE - WAS MISSING!

exports.register = async (req, res, next) => {
    try {
        const { name, email, password } = req.body;

        if (!name || !email || !password) {
            return res.status(400).json({ status: false, error: "Name, email and password are required" });
        }

        const duplicate = await UserServices.getUserByEmail(email);
        if (duplicate) {
            return res.status(400).json({ status: false, error: `UserName ${email} already registered` });
        }

        const response = await UserServices.registerUser({ name, email, password });

        res.json({ status: true, success: 'User registered successfully' });

    } catch (err) {
        console.error(err);
        res.status(500).json({ status: false, error: err.message });
    }
};

exports.login = async (req, res, next) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            throw new Error('Parameter are not correct');
        }
        let user = await UserServices.checkUser(email);
        if (!user) {
            throw new Error('User does not exist');
        }

        const isPasswordCorrect = await user.comparePassword(password);

        if (isPasswordCorrect === false) {
            throw new Error(`Username or Password does not match`);
        }

        // Creating Token
        let tokenData = { _id: user._id, email: user.email, name: user.name };
    
        const token = await UserServices.generateAccessToken(tokenData,"secret","1h")

        res.status(200).json({ status: true, success: "sendData", token: token });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
};

exports.addToFavorites = async (req, res) => {
  try {
    const { bookId } = req.body;
    console.log('🔥 ADD TO FAVORITES:', { bookId, userId: req.user._id }); // Debug log
    
    if (!bookId) return res.status(400).json({ status: false, error: "bookId is required" });

    const user = req.user; // set by verifyToken
    const book = await Book.findById(bookId);
    if (!book) return res.status(404).json({ status: false, error: "Book not found" });

    if (user.favorites.includes(bookId)) {
      return res.status(400).json({ status: false, error: "Book already in favorites" });
    }

    user.favorites.push(bookId);
    await user.save();

    console.log('✅ ADDED TO FAVORITES:', bookId); // Debug log
    res.status(200).json({ status: true, success: "Book added to favorites", data: user.favorites });
  } catch (err) {
    console.error('❌ ADD TO FAVORITES ERROR:', err);
    res.status(500).json({ status: false, error: err.message });
  }
};

exports.getFavorites = async (req, res) => {
  try {
    console.log('📚 GET FAVORITES:', { userId: req.user._id }); // Debug log
    
    // NOW User is imported, so this works!
    const user = await User.findById(req.user._id).populate("favorites");
    
    if (!user) {
      return res.status(404).json({ status: false, error: "User not found" });
    }
    
    const favorites = user.favorites || [];
    console.log('✅ FAVORITES COUNT:', favorites.length); // Debug log
    
    res.status(200).json({ 
      status: true, 
      data: favorites,
      count: favorites.length 
    });
  } catch (err) {
    console.error('❌ GET FAVORITES ERROR:', err);
    res.status(500).json({ status: false, error: err.message });
  }
};

// ADD THESE NEW METHODS FOR COMPLETE FAVORITES FUNCTIONALITY

// Remove from favorites
exports.removeFromFavorites = async (req, res) => {
  try {
    const { bookId } = req.body;
    console.log('💔 REMOVE FROM FAVORITES:', { bookId, userId: req.user._id });
    
    if (!bookId) return res.status(400).json({ status: false, error: "bookId is required" });

    const user = req.user;
    const book = await Book.findById(bookId);
    if (!book) return res.status(404).json({ status: false, error: "Book not found" });

    const favoriteIndex = user.favorites.indexOf(bookId);
    if (favoriteIndex === -1) {
      return res.status(400).json({ status: false, error: "Book not in favorites" });
    }

    user.favorites.splice(favoriteIndex, 1);
    await user.save();

    console.log('✅ REMOVED FROM FAVORITES:', bookId);
    res.status(200).json({ status: true, success: "Book removed from favorites", data: user.favorites });
  } catch (err) {
    console.error('❌ REMOVE FROM FAVORITES ERROR:', err);
    res.status(500).json({ status: false, error: err.message });
  }
};

// Check if book is favorite
exports.isFavorite = async (req, res) => {
  try {
    const { bookId } = req.body;
    console.log('❓ CHECK FAVORITE:', { bookId, userId: req.user._id });
    
    if (!bookId) return res.status(400).json({ status: false, error: "bookId is required" });

    const user = req.user;
    const isFavorite = user.favorites.includes(bookId);

    console.log('✅ IS FAVORITE:', isFavorite);
    res.status(200).json({ 
      status: true, 
      data: { 
        bookId, 
        isFavorite,
        favorites: user.favorites 
      } 
    });
  } catch (err) {
    console.error('❌ CHECK FAVORITE ERROR:', err);
    res.status(500).json({ status: false, error: err.message });
  }
};

// Toggle favorite (add or remove)
exports.toggleFavorite = async (req, res) => {
  try {
    const { bookId } = req.body;
    console.log('🔄 TOGGLE FAVORITE:', { bookId, userId: req.user._id });
    
    if (!bookId) return res.status(400).json({ status: false, error: "bookId is required" });

    const user = req.user;
    const book = await Book.findById(bookId);
    if (!book) return res.status(404).json({ status: false, error: "Book not found" });

    const isCurrentlyFavorite = user.favorites.includes(bookId);
    
    if (isCurrentlyFavorite) {
      // Remove from favorites
      const favoriteIndex = user.favorites.indexOf(bookId);
      user.favorites.splice(favoriteIndex, 1);
      await user.save();
      console.log('✅ REMOVED FROM FAVORITES (TOGGLE)');
      res.status(200).json({ 
        status: true, 
        success: "Book removed from favorites", 
        data: { 
          bookId, 
          isFavorite: false,
          favorites: user.favorites 
        } 
      });
    } else {
      // Add to favorites
      user.favorites.push(bookId);
      await user.save();
      console.log('✅ ADDED TO FAVORITES (TOGGLE)');
      res.status(200).json({ 
        status: true, 
        success: "Book added to favorites", 
        data: { 
          bookId, 
          isFavorite: true,
          favorites: user.favorites 
        } 
      });
    }
  } catch (err) {
    console.error('❌ TOGGLE FAVORITE ERROR:', err);
    res.status(500).json({ status: false, error: err.message });
  }
};

// Export all methods
module.exports = {
  register: exports.register,
  login: exports.login,
  addToFavorites: exports.addToFavorites,
  getFavorites: exports.getFavorites,
  removeFromFavorites: exports.removeFromFavorites,
  isFavorite: exports.isFavorite,
  toggleFavorite: exports.toggleFavorite
};
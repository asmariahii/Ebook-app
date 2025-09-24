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
let tokenData = { _id: user._id, email: user.email, name: user.name, role: user.role };  // ADD role: user.role    
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
// Show user profile details
const getProfile = async (req, res) => {
  try {
    console.log('👤 GET PROFILE:', { userId: req.user._id });
    
    const user = req.user;
    
    // Return profile data without sensitive information
    const profileData = {
      _id: user._id,
      name: user.name,
      email: user.email,
      favorites: user.favorites,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt
    };
    
    console.log('✅ PROFILE DATA:', { name: user.name, email: user.email });
    res.status(200).json({ 
      status: true, 
      data: profileData,
      message: "Profile fetched successfully"
    });
  } catch (err) {
    console.error('❌ GET PROFILE ERROR:', err);
    res.status(500).json({ status: false, error: err.message });
  }
};

// Update user profile
const updateProfile = async (req, res) => {
  try {
    console.log('✏️ UPDATE PROFILE:', { userId: req.user._id, body: req.body });
    
    const { name, currentPassword, newPassword } = req.body;
    const user = req.user;
    
    // Validate input
    if (!name && !currentPassword && !newPassword) {
      return res.status(400).json({ 
        status: false, 
        error: "At least one field (name or password) must be provided" 
      });
    }
    
    // Update name if provided
    if (name && name.trim() !== '') {
      user.name = name.trim();
    }
    
    // Update password if new password is provided
    if (newPassword) {
      if (!currentPassword) {
        return res.status(400).json({ 
          status: false, 
          error: "Current password is required to change password" 
        });
      }
      
      // Verify current password
      const isCurrentPasswordCorrect = await user.comparePassword(currentPassword);
      if (!isCurrentPasswordCorrect) {
        return res.status(400).json({ 
          status: false, 
          error: "Current password is incorrect" 
        });
      }
      
      // Check password strength
      if (newPassword.length < 6) {
        return res.status(400).json({ 
          status: false, 
          error: "New password must be at least 6 characters long" 
        });
      }
      
      // Update password
      user.password = newPassword;
    }
    
    // Save updated user
    await user.save();
    
    // Generate new token with updated data
    const tokenData = { _id: user._id, email: user.email, name: user.name };
    const token = await UserServices.generateAccessToken(tokenData, "secret", "1h");
    
    console.log('✅ PROFILE UPDATED:', { name: user.name });
    res.status(200).json({ 
      status: true, 
      success: "Profile updated successfully",
      data: {
        user: {
          _id: user._id,
          name: user.name,
          email: user.email,
          updatedAt: user.updatedAt
        },
        token: token
      }
    });
  } catch (err) {
    console.error('❌ UPDATE PROFILE ERROR:', err);
    res.status(500).json({ status: false, error: err.message });
  }
};

// Update profile picture (requires multer setup)
const updateProfilePicture = async (req, res) => {
  try {
    console.log('🖼️ UPDATE PROFILE PICTURE:', { userId: req.user._id });
    
    if (!req.file) {
      return res.status(400).json({ 
        status: false, 
        error: "No image file uploaded" 
      });
    }
    
    const user = req.user;
    user.profilePicture = `/uploads/${req.file.filename}`;
    await user.save();
    
    // Generate new token
    const tokenData = { _id: user._id, email: user.email, name: user.name };
    const token = await UserServices.generateAccessToken(tokenData, "secret", "1h");
    
    console.log('✅ PROFILE PICTURE UPDATED');
    res.status(200).json({ 
      status: true, 
      success: "Profile picture updated successfully",
      data: {
        profilePicture: user.profilePicture,
        token: token
      }
    });
  } catch (err) {
    console.error('❌ UPDATE PROFILE PICTURE ERROR:', err);
    res.status(500).json({ status: false, error: err.message });
  }
};

// GET ALL USERS (for admin only)
exports.getAllUsers = async (req, res) => {
  try {
    // Check if user is admin
    if (req.user.role !== 'admin') {
      return res.status(403).json({ status: false, error: 'Access denied. Admin only' });
    }

    const users = await User.find()
      .select('-password') // Exclude password
      .sort({ createdAt: -1 });

    res.status(200).json({ 
      status: true, 
      data: users,
      count: users.length 
    });
  } catch (err) {
    console.error('❌ GET ALL USERS ERROR:', err);
    res.status(500).json({ status: false, error: err.message });
  }
};

// Logout user
exports.logout = async (req, res) => {
  try {
    console.log('🚪 LOGOUT:', { userId: req.user._id });

    // Since JWT is stateless, the client should remove the token
    // Optionally, you can implement token blacklisting here if needed
    res.status(200).json({
      status: true,
      success: "User logged out successfully",
    });
  } catch (err) {
    console.error('❌ LOGOUT ERROR:', err);
    res.status(500).json({ status: false, error: err.message });
  }
};

// DELETE USER (for admin only)
exports.deleteUser = async (req, res) => {
  try {
    const { userId } = req.params;
    
    // Check if user is admin
    if (req.user.role !== 'admin') {
      return res.status(403).json({ status: false, error: 'Access denied. Admin only' });
    }

    // Prevent admin from deleting themselves
    if (req.user._id.toString() === userId) {
      return res.status(400).json({ status: false, error: 'Cannot delete yourself' });
    }

    const user = await User.findByIdAndDelete(userId);
    if (!user) {
      return res.status(404).json({ status: false, error: 'User not found' });
    }

    res.status(200).json({ 
      status: true, 
      success: 'User deleted successfully',
      data: { deletedUserId: userId }
    });
  } catch (err) {
    console.error('❌ DELETE USER ERROR:', err);
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
  toggleFavorite: exports.toggleFavorite,
  deleteUser: exports.deleteUser,
  getAllUsers: exports.getAllUsers,

  getProfile,
  updateProfile,
  updateProfilePicture,
  logout: exports.logout


};
const UserModel = require("../model/user.model");
const jwt = require("jsonwebtoken");

class UserServices {
  static async registerUser({ name, email, password }) {
    try {
      const createUser = new UserModel({ name, email, password });
      return await createUser.save();
    } catch (err) {
      throw err;
    }
  }

  static async getUserByEmail(email) {
    return await UserModel.findOne({ email });
  }

  static async checkUser(email) {
    return await UserModel.findOne({ email });
  }

  static async generateAccessToken(tokenData, JWTSecret_Key, JWT_EXPIRE) {
    return jwt.sign(tokenData, JWTSecret_Key, { expiresIn: JWT_EXPIRE });
  }
}

// Middleware
const verifyToken = async (req, res, next) => {
  try {
    const authHeader = req.headers["authorization"];
    if (!authHeader) return res.status(401).json({ status: false, error: "No token provided" });

    const token = authHeader.split(" ")[1];
    const decoded = jwt.verify(token, "secret"); // same secret as login
    const user = await UserModel.findById(decoded._id);
    if (!user) return res.status(404).json({ status: false, error: "User not found" });

    req.user = user;
    next();
  } catch (err) {
    return res.status(403).json({ status: false, error: "Unauthorized" });
  }
};



// Show user profile details
exports.getProfile = async (req, res) => {
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
exports.updateProfile = async (req, res) => {
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
      // Check if email is being changed (if you want to allow email updates)
      const emailExists = await UserServices.getUserByEmail(req.body.email);
      if (emailExists && emailExists._id.toString() !== user._id.toString()) {
        return res.status(400).json({ 
          status: false, 
          error: "Email is already registered with another account" 
        });
      }
      
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
      
      // Check password strength (optional - you can customize this)
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

// Update profile picture (if you want to add this feature later)
exports.updateProfilePicture = async (req, res) => {
  try {
    console.log('🖼️ UPDATE PROFILE PICTURE:', { userId: req.user._id });
    
    if (!req.file) {
      return res.status(400).json({ 
        status: false, 
        error: "No image file uploaded" 
      });
    }
    
    const user = req.user;
    
    // You'll need to handle file upload middleware (multer) for this
    // Store file path or URL in user model
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

// Export both
module.exports = { UserServices, verifyToken };

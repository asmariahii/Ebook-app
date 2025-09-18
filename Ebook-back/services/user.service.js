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

// Export both
module.exports = { UserServices, verifyToken };

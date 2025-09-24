const router = require("express").Router();
const UserController = require('../controller/user.controller');
const { UserServices, verifyToken } = require("../services/user.service");

// Basic auth routes
router.post("/register", UserController.register);
router.post("/login", UserController.login);

// Favorites routes - ALL PROTECTED
router.post("/favorites", verifyToken, UserController.addToFavorites);
router.get("/favorites", verifyToken, UserController.getFavorites);
router.post("/favorites/remove", verifyToken, UserController.removeFromFavorites);
router.post("/favorites/check", verifyToken, UserController.isFavorite);
router.post("/favorites/toggle", verifyToken, UserController.toggleFavorite);

// Profile routes
router.get('/profile', verifyToken, UserController.getProfile);
router.put('/profile', verifyToken, UserController.updateProfile);


//admin
router.get('/users', verifyToken, UserController.getAllUsers);
router.delete('/users/:userId', verifyToken, UserController.deleteUser);
router.post("/logout", verifyToken, UserController.logout);

// Profile picture route - RECEIVE UPLOAD AS PARAMETER
module.exports = (upload) => {
  // Profile picture route
  router.post('/profile/picture', verifyToken, upload.single('profilePicture'), UserController.updateProfilePicture);
  
  return router;
};
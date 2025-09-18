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



module.exports = router;
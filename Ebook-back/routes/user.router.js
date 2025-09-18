const router = require("express").Router();
const UserController = require('../controller/user.controller');
const { UserServices, verifyToken } = require("../services/user.service");

router.post("/register", UserController.register);
router.post("/login", UserController.login);



router.post("/favorites", verifyToken, UserController.addToFavorites);
router.get("/favorites", verifyToken, UserController.getFavorites);

module.exports = router;

const { UserServices } = require('../services/user.service');
const Book = require("../model/book.model");



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

        let tokenData;
        tokenData = { _id: user._id, email: user.email, name: user.name };
    

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
    if (!bookId) return res.status(400).json({ status: false, error: "bookId is required" });

    const user = req.user; // set by verifyToken
    const book = await Book.findById(bookId);
    if (!book) return res.status(404).json({ status: false, error: "Book not found" });

    if (user.favorites.includes(bookId)) {
      return res.status(400).json({ status: false, error: "Book already in favorites" });
    }

    user.favorites.push(bookId);
    await user.save();

    res.status(200).json({ status: true, success: "Book added to favorites", data: user.favorites });
  } catch (err) {
    console.error(err);
    res.status(500).json({ status: false, error: err.message });
  }
};

exports.getFavorites = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).populate("favorites");
    res.status(200).json({ status: true, data: user.favorites });
  } catch (err) {
    console.error(err);
    res.status(500).json({ status: false, error: err.message });
  }
};
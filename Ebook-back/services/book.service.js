const BookModel = require("../model/book.model");

class BookServices {
    static async addBook(data) {
        const book = new BookModel(data);
        return await book.save();
    }

    static async getAllBooks() {
        return await BookModel.find();
    }

    static async getTrendingBooks() {
        return await BookModel.find({ isTrending: true });
    }

    static async getBookById(id) {
        return await BookModel.findById(id);
    }
}

module.exports = BookServices;

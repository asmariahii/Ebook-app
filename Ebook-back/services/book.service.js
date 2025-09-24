const BookModel = require('../model/book.model');


let searchCount = 0; // In-memory counter for searches (resets on server restart)

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

  // Add trackSearch as a static method
  static async trackSearch() {
    searchCount += 1;
    return searchCount;
  }

  // Add getAnalytics as a static method
  static async getAnalytics() {
    try {
      const totalBooks = await BookModel.countDocuments();
      const trendingBooks = await BookModel.countDocuments({ isTrending: true });

      return {
        totalBooks,
        trendingBooks,
        searches: searchCount,
      };
    } catch (err) {
      throw new Error('Failed to fetch analytics: ' + err.message);
    }
  }
}

module.exports = BookServices;
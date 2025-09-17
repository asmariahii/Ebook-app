import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/book_model.dart';

class BookService {
  // Fetch all books
  static Future<List<BookModel>> fetchBooks() async {
    final response = await http.get(Uri.parse(booksUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((e) => BookModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load books");
    }
  }

  // Fetch trending books
  static Future<List<BookModel>> fetchTrending() async {
    final response = await http.get(Uri.parse(trendingBooksUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((e) => BookModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load trending books");
    }
  }
}

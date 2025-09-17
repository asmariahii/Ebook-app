import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config.dart'; // contains your base URLs
import '../models/book_model.dart';

class BookController extends GetxController {
  static BookController get instance => Get.find();

  // Observable lists for UI
  var allBooks = <BookModel>[].obs;
  var trendingBooks = <BookModel>[].obs;

  // Fetch all books
  Future<void> fetchAllBooks() async {
    try {
      final response = await http.get(Uri.parse(booksUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        allBooks.value = data.map((e) => BookModel.fromJson(e)).toList();
      } else {
        print("Error fetching books: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Fetch trending books
  Future<void> fetchTrendingBooks() async {
    try {
      final response = await http.get(Uri.parse("$booksUrl/trending"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        trendingBooks.value = data.map((e) => BookModel.fromJson(e)).toList();
      } else {
        print("Error fetching trending books: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Optional: fetch single book by ID
  Future<BookModel?> fetchBookById(String id) async {
    try {
      final response = await http.get(Uri.parse("$booksUrl/$id"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        return BookModel.fromJson(data);
      }
    } catch (e) {
      print("Error fetching book by ID: $e");
    }
    return null;
  }
}

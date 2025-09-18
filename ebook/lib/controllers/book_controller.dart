import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // ADD THIS IMPORT
import '../config.dart'; // contains your base URLs
import '../models/book_model.dart';

class BookController extends GetxController {
  static BookController get instance => Get.find();

  // Observable lists for UI
  var allBooks = <BookModel>[].obs;
  var trendingBooks = <BookModel>[].obs;

  // ADD THESE FAVORITES PROPERTIES
  var userFavorites = <String>[].obs;
  bool isLoadingFavorites = false;

  // Your existing methods (keep them unchanged)
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

  // ADD THESE NEW FAVORITES METHODS (Keep your existing code above unchanged)

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Check if book is in favorites
  bool isBookInFavorites(String bookId) {
    return userFavorites.contains(bookId);
  }

  // Add to favorites - THE MAIN METHOD YOU NEED
  Future<bool> addToFavorites(String bookId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print("❌ No token found - user not logged in");
        return false;
      }

      print("🔄 Adding book $bookId to favorites...");

      final response = await http.post(
        Uri.parse(favoritesUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Same format as Postman
        },
        body: jsonEncode({"bookId": bookId}),
      );

      print("📡 Add to favorites response: ${response.statusCode}");
      print("📄 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == true) {
          // Add to local favorites list
          if (!userFavorites.contains(bookId)) {
            userFavorites.add(bookId);
          }
          print("✅ Successfully added book $bookId to favorites");
          return true;
        } else {
          print("❌ Server error: ${jsonResponse['error']}");
          // If already in favorites, still return true
          if (jsonResponse['error']?.contains('already in favorites') ?? false) {
            userFavorites.add(bookId);
            return true;
          }
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
      }

      return false;
    } catch (e) {
      print("❌ Error adding to favorites: $e");
      return false;
    }
  }

  // Get favorites from server
  Future<void> loadFavorites() async {
    try {
      isLoadingFavorites = true;
      final token = await _getToken();
      if (token == null) {
        print("❌ No token for loading favorites");
        return;
      }

      final response = await http.get(
        Uri.parse(favoritesUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == true) {
          final favoritesData = jsonResponse['data'] ?? [];
          userFavorites.value = favoritesData.map((e) => e.toString()).toList();
          print("✅ Loaded ${userFavorites.length} favorites");
        }
      }
    } catch (e) {
      print("❌ Error loading favorites: $e");
    } finally {
      isLoadingFavorites = false;
    }
  }
}
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/book_model.dart';
import 'dart:math' as math;

class BookController extends GetxController {
  static BookController get instance => Get.find();

  // Observable lists for UI
  var allBooks = <BookModel>[].obs;
  var trendingBooks = <BookModel>[].obs;

  // FIXED: Make isLoadingFavorites observable
  var userFavorites = <String>[].obs;
  var isLoadingFavorites = false.obs; // ← FIXED: Now observable!

  var analyticsData = {}.obs; // Store totalBooks, trendingBooks, searches
  var isLoadingAnalytics = false.obs;


  // Your existing methods
  Future<void> fetchAllBooks() async {
    try {
      final response = await http.get(Uri.parse(booksUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        allBooks.value = data.map((e) => BookModel.fromJson(e)).toList();
        print("✅ Loaded ${allBooks.length} books");
      } else {
        print("Error fetching books: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching books: $e");
    }
  }

  Future<void> fetchTrendingBooks() async {
    try {
      final response = await http.get(Uri.parse(trendingBooksUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        trendingBooks.value = data.map((e) => BookModel.fromJson(e)).toList();
        print("✅ Loaded ${trendingBooks.length} trending books");
      } else {
        print("Error fetching trending books: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching trending books: $e");
    }
  }

  Future<BookModel?> fetchBookById(String id) async {
    try {
      print("📖 Fetching book details for ID: $id");
      
      final response = await http.get(
        Uri.parse("$booksUrl/$id"), // FIXED: Added missing slash between booksUrl and id
        headers: {"Content-Type": "application/json"},
      );

      print("📡 Book detail response: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == true) {
          final data = jsonResponse['data'];
          print("✅ Book loaded: ${data['title'] ?? 'No title'}");
          return BookModel.fromJson(data);
        } else {
          print("❌ Server returned false status: ${jsonResponse['error']}");
        }
      } else {
        print("❌ HTTP Error fetching book: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching book by ID: $e");
    }
    return null;
  }

  

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Check if book is in favorites
  bool isBookInFavorites(String bookId) {
    return userFavorites.contains(bookId);
  }

  // Add to favorites - YOUR WORKING METHOD
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
          "Authorization": "Bearer $token",
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
            if (!userFavorites.contains(bookId)) {
              userFavorites.add(bookId);
            }
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

  // Remove from favorites
  Future<bool> removeFromFavorites(String bookId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print("❌ No token found - user not logged in");
        return false;
      }

      print("💔 Removing book $bookId from favorites...");

      final response = await http.post(
        Uri.parse(favoritesRemoveUrl), // Use the correct remove URL
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"bookId": bookId}),
      );

      print("📡 Remove from favorites response: ${response.statusCode}");
      print("📄 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == true) {
          // Remove from local favorites list
          if (userFavorites.contains(bookId)) {
            userFavorites.remove(bookId);
          }
          print("✅ Successfully removed book $bookId from favorites");
          return true;
        } else {
          print("❌ Server error: ${jsonResponse['error']}");
          // If not in favorites, still remove locally
          if (jsonResponse['error']?.contains('not in favorites') ?? false) {
            if (userFavorites.contains(bookId)) {
              userFavorites.remove(bookId);
            }
            return true;
          }
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
      }

      return false;
    } catch (e) {
      print("❌ Error removing from favorites: $e");
      return false;
    }
  }

  // Toggle favorite (add or remove)
  Future<bool> toggleFavorite(String bookId) async {
    if (isBookInFavorites(bookId)) {
      return await removeFromFavorites(bookId);
    } else {
      return await addToFavorites(bookId);
    }
  }

  // FIXED: loadFavorites method with proper type handling
  Future<void> loadFavorites() async {
    try {
      // FIXED: Use .value for observable
      isLoadingFavorites.value = true;
      
      final token = await _getToken();
      if (token == null) {
        print("❌ No token for loading favorites");
        isLoadingFavorites.value = false;
        return;
      }

      print("🔄 Loading favorites for user...");

      final response = await http.get(
        Uri.parse(favoritesUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("📡 Get favorites response: ${response.statusCode}");
      print("📄 Get favorites body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == true) {
          final favoritesData = jsonResponse['data'] ?? [];
          
          // FIXED: Handle both book IDs and populated book objects
          List<String> favoriteIds = [];
          
          if (favoritesData is List) {
            for (var item in favoritesData) {
              if (item is String) {
                // Case 1: Just book ID (string)
                favoriteIds.add(item);
              } else if (item is Map<String, dynamic>) {
                // Case 2: Populated book object
                if (item['_id'] != null) {
                  favoriteIds.add(item['_id'].toString());
                } else if (item['id'] != null) {
                  favoriteIds.add(item['id'].toString());
                }
              }
            }
          }
          
          userFavorites.value = favoriteIds;
          print("✅ Loaded ${userFavorites.length} favorite book IDs: $favoriteIds");
        } else {
          print("❌ Server returned false status: ${jsonResponse['error']}");
          userFavorites.clear();
        }
      } else {
        print("❌ HTTP Error getting favorites: ${response.statusCode}");
        print("Response: ${response.body}");
        userFavorites.clear();
      }
    } catch (e) {
      print("❌ Error loading favorites: $e");
      userFavorites.clear();
    } finally {
      // FIXED: Use .value for observable
      isLoadingFavorites.value = false;
    }
  }

  // 🔍 Search books by title or author
Future<List<BookModel>> searchBooks(String query) async {
  try {
    if (query.trim().isEmpty) {
      return []; // Return empty list for empty query
    }

    print("🔍 Searching for: '$query'");
    
    final response = await http.get(
      Uri.parse("$booksUrl/search?q=${Uri.encodeComponent(query)}"),
      headers: {"Content-Type": "application/json"},
    );

    print("📡 Search response: ${response.statusCode}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == true) {
        final data = jsonResponse['data'] as List;
        final searchResults = data.map((e) => BookModel.fromJson(e)).toList();
        print("✅ Found ${searchResults.length} search results");
        return searchResults;
      } else {
        print("❌ Search failed: ${jsonResponse['error']}");
        return [];
      }
    } else {
      print("❌ Search HTTP Error: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    print("❌ Search error: $e");
    return [];
  }
}

// Observable for search results
var searchResults = <BookModel>[].obs;
var isSearching = false.obs;
var searchQuery = ''.obs;

// Clear search results
void clearSearch() {
  searchResults.clear();
  searchQuery.value = '';
  isSearching.value = false;
}

  // Clear favorites (for logout)
  void clearFavorites() {
    userFavorites.clear();
    isLoadingFavorites.value = false;
  }

  // New method to fetch analytics
  Future<void> fetchAnalytics() async {
    try {
      isLoadingAnalytics.value = true;
      final token = await _getToken();
      if (token == null) {
        print("❌ No token found - user not logged in");
        Get.snackbar(
          'Error',
          'Authentication required',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color.fromARGB(255, 60, 120, 68),
          colorText: Colors.white,
        );
        return;
      }

      final response = await http.get(
        Uri.parse('$booksUrl/analytics'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📡 Analytics response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == true) {
          analyticsData.value = jsonResponse['data'];
          print("✅ Analytics loaded: ${analyticsData.value}");
        } else {
          print("❌ Analytics failed: ${jsonResponse['error']}");
          Get.snackbar(
            'Error',
            jsonResponse['error'] ?? 'Failed to load analytics',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color.fromARGB(255, 60, 120, 68),
            colorText: Colors.white,
          );
        }
      } else {
        print("❌ HTTP Error fetching analytics: ${response.statusCode}");
        Get.snackbar(
          'Error',
          'Failed to load analytics: ${response.statusCode}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color.fromARGB(255, 60, 120, 68),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("❌ Error fetching analytics: $e");
      Get.snackbar(
        'Error',
        'Network error: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color.fromARGB(255, 60, 120, 68),
        colorText: Colors.white,
      );
    } finally {
      isLoadingAnalytics.value = false;
    }
  }
}
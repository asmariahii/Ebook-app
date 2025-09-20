import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ebook/controllers/book_controller.dart';
import 'package:ebook/models/book_model.dart';
import '../../home/detail_page.dart'; // Adjust path as needed
import 'package:ebook/utils/constants/colors.dart';
import 'dart:async';

class NavSearchPage extends StatefulWidget {
  const NavSearchPage({super.key});

  @override
  State<NavSearchPage> createState() => _NavSearchPageState();
}

class _NavSearchPageState extends State<NavSearchPage> {
  final BookController bookController = Get.find<BookController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Clear search results when page opens
    bookController.clearSearch();
    _searchFocusNode.requestFocus(); // Auto-focus search bar
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✨ Subtle gradient background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF8F9FA),
              const Color(0xFFFEF8F8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ✨ Enhanced Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Search Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.search,
                        color: TColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Search Input
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Search books by title or author...',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: TColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                        onChanged: (value) {
                          bookController.searchQuery.value = value;
                          // Debounce search (optional - call immediately for now)
                          _performSearch(value);
                        },
                        onSubmitted: (value) => _performSearch(value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Clear Button
                    Obx(() => bookController.searchQuery.value.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.clear, color: Colors.red, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                bookController.clearSearch();
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          )
                        : const SizedBox.shrink()),
                  ],
                ),
              ),

              // ✨ Search Results
              Expanded(
                child: Obx(() {
                  final results = bookController.searchResults;
                  final isSearching = bookController.isSearching.value;
                  final query = bookController.searchQuery.value;

                  if (isSearching) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Searching...",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (query.isEmpty) {
                    return _buildEmptySearchState();
                  }

                  if (results.isEmpty) {
                    return _buildNoResultsState(query);
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _performSearch(query),
                    color: TColors.primary,
                    backgroundColor: Colors.white,
                    displacement: 60,
                    child: CustomScrollView(
                      slivers: [
                        // ✨ Search Results Header
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [TColors.primary.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: TColors.primary.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: TColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "Found ${results.length} results for '$query'",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final book = results[index];
                                return _buildSearchResultCard(book);
                              },
                              childCount: results.length,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✨ Perform search with debouncing
  Timer? _debounce;
  void _performSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.trim().isNotEmpty) {
        bookController.isSearching.value = true;
        bookController.searchBooks(query).then((results) {
          bookController.searchResults.assignAll(results);
          bookController.isSearching.value = false;
        }).catchError((error) {
          print("Search error: $error");
          bookController.searchResults.clear();
          bookController.isSearching.value = false;
        });
      } else {
        bookController.clearSearch();
      }
    });
  }

  // ✨ Empty search state
  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search,
              size: 64,
              color: TColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Search for books",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Type in the search bar above to find books by title or author",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: TColors.primary.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to popular books or something
                Get.snackbar(
                  "Tip",
                  "Try searching for 'Harry Potter' or 'Jane Austen'",
                  backgroundColor: TColors.primary,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
              },
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text("Search Tips"),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✨ No results state
  Widget _buildNoResultsState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            "No results found",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              "Try searching for something else or check your spelling",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                bookController.clearSearch();
                _searchFocusNode.requestFocus();
              },
              icon: const Icon(Icons.clear),
              label: const Text("Clear Search"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✨ Search result card
  Widget _buildSearchResultCard(BookModel book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Detailpage(bookModel: book),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover
              Hero(
                tag: 'book_cover_${book.id}',
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: book.cover != null && book.cover!.isNotEmpty
                        ? Image.network(
                            book.cover!,
                            width: 70,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 70,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.grey[300]!, Colors.grey[400]!],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.book_outlined,
                                  size: 35,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 70,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.grey[300]!, Colors.grey[400]!],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.book_outlined,
                              size: 35,
                              color: Colors.grey[600],
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Book details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title ?? "Unknown Title",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (book.author != null && book.author!.isNotEmpty)
                      Text(
                        book.author!,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (book.description != null && book.description!.isNotEmpty)
                      Text(
                        book.description!.length > 80
                            ? "${book.description!.substring(0, 80)}..."
                            : book.description!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Favorite button
              Obx(() {
                final isFavorite = bookController.isBookInFavorites(book.id ?? '');
                return Container(
                  decoration: BoxDecoration(
                    color: isFavorite ? Colors.red[50] : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () async {
                      final success = await bookController.toggleFavorite(book.id ?? '');
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFavorite 
                                  ? "Removed from favorites" 
                                  : "Added to favorites",
                            ),
                            backgroundColor: isFavorite ? Colors.red : Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      isFavorite 
                          ? Icons.favorite 
                          : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey[600],
                      size: 24,
                    ),
                    tooltip: isFavorite ? "Remove from favorites" : "Add to favorites",
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// Add this import at the top of your file for Timer

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/book_model.dart';
import '../components/trending_widget.dart';
import '../../login/signin_page.dart';
import '../components/nouveatue_widget.dart';
import '../../../services/book_service.dart';
import 'package:ebook/utils/constants/colors.dart';

class NavHomePage extends StatefulWidget {
  final String token; // Required token parameter

  const NavHomePage({super.key, required this.token});

  @override
  State<NavHomePage> createState() => _NavHomePageState();
}

class _NavHomePageState extends State<NavHomePage> {
  late String name;
  late String userId;
  late SharedPreferences prefs;

  List<BookModel> allBooks = [];
  List<BookModel> trendingBooks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _decodeToken();
    _initSharedPref();
    _loadBooks();
  }

  void _decodeToken() {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    name = decodedToken['name'] ?? "User";
    userId = decodedToken['_id'];
  }

  void _initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _logout() async {
    await prefs.remove('token');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SigninPage()),
      (route) => false,
    );
  }

  void _loadBooks() async {
    try {
      final books = await BookService.fetchBooks();
      final trending = await BookService.fetchTrending();
if (mounted) {
  setState(() {
    allBooks = books;
    trendingBooks = trending;
    isLoading = false;
  });
}
    } catch (e) {
      print("Error fetching books: $e");
if (mounted) {
  setState(() => isLoading = false);
}    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✨ Subtle gradient background for warmth
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFFEF8F8),
            ],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Loading your books...",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16), // Space after AppBar

                      // ✨ "Made for you" section with gradient header
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [TColors.primary.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: TColors.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: TColors.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Made for you",
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () {
                                  // TODO: Implement notifications
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text("Notifications coming soon!"),
                                      backgroundColor: TColors.primary,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.notifications_none_rounded, color: Colors.grey),
                                tooltip: "Notifications",
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ✨ Enhanced New Releases Horizontal List
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(right: 8),
                          itemCount: allBooks.length,
                          itemBuilder: (context, index) {
                            final book = allBooks[index];
                            return Container(
                              margin: const EdgeInsets.only(left: 8, bottom: 16),
                              child: NouveauteWidget(bookModel: book),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ✨ "Trending now" section with gradient header
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange.withOpacity(0.1), Colors.red.withOpacity(0.05)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.orange.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.trending_up_rounded,
                              color: Colors.orange[700],
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Trending now",
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ✨ Enhanced Trending Vertical List
                      ListView.builder(
                        itemCount: trendingBooks.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final book = trendingBooks[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: TrendingWidget(bookModel: book),
                          );
                        },
                      ),

                      // ✨ Add some bottom padding for better spacing
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
        ),
      ),
      // ✨ Enhanced AppBar with floating effect
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            "Welcome, $name",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_outlined, color: Colors.red),
              onPressed: _logout,
              tooltip: "Logout",
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
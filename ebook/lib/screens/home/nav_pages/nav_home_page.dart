import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/book_model.dart';
import '../components/trending_widget.dart';
import '../../login/signin_page.dart';
import '../components/nouveatue_widget.dart';
import '../../../services/book_service.dart';

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
      setState(() {
        allBooks = books;
        trendingBooks = trending;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching books: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          title: Text("Welcome, $name"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_outlined, color: Colors.black),
              onPressed: _logout,
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row
                    Row(
                      children: [
                        Text(
                          "Made for you",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_none_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // New Releases Horizontal List
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: allBooks.length,
                        itemBuilder: (context, index) =>
                            NouveauteWidget(bookModel: allBooks[index]),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Trending Vertical List
                    Text(
                      "Trending now",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    ListView.builder(
                      itemCount: trendingBooks.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) =>
                          TrendingWidget(bookModel: trendingBooks[index]),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

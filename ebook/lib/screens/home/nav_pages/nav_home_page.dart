import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/book_model.dart';
import '../components/nouveatue_widget.dart';
import '../components/trending_widget.dart';
import '../../login/signin_page.dart';

class NavHomePage extends StatefulWidget {
  final String token; // Required token parameter

  const NavHomePage({super.key, required this.token});

  @override
  State<NavHomePage> createState() => _NavHomePageState();
}

class _NavHomePageState extends State<NavHomePage> {
  late String name; // use name instead of email
  late String userId;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _decodeToken();
    _initSharedPref();
  }

  // Decode JWT to get name and userId
  void _decodeToken() {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    name = decodedToken['name'] ?? "User"; // Now this will be the actual name
    userId = decodedToken['_id'];
    print("User ID: $userId, Name: $name");
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          title: Text(
            "Welcome, $name", // display user name
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_outlined, color: Colors.black),
              onPressed: _logout,
            ),
          ],
        ),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(5),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row with actions
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
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.replay_rounded),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // New Releases Horizontal List
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: bookList.length,
                    itemBuilder: (context, index) =>
                        NouveauteWidget(bookModel: bookList[index]),
                  ),
                ),
                const SizedBox(height: 10),

                // Trending Horizontal List
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: trendingBooks.length,
                    itemBuilder: (context, index) =>
                        NouveauteWidget(bookModel: trendingBooks[index]),
                  ),
                ),
                const SizedBox(height: 10),

                // Trending Vertical List
                Text(
                  "Trending now",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                ListView.builder(
                  itemCount: bookList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) =>
                      TrendingWidget(bookModel: bookList[index]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

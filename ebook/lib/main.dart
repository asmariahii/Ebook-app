import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ebook/screens/nav_pages/nav_home_page.dart';
import 'package:ebook/screens/home/route_pages.dart';


import 'package:ebook/screens/login/signin_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mytoken = prefs.getString('token');

  runApp(MyApp(token: mytoken));
}

class MyApp extends StatelessWidget {
  final String? token;
  const MyApp({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: token != null && !JwtDecoder.isExpired(token!)
          ? RoutePages(token: token!) // pass token here
          : SigninPage(),
    );
  }
}

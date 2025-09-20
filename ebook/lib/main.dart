import 'package:ebook/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'screens/login/signin_page.dart';
import 'screens/home/route_pages.dart';
import 'controllers/auth_controller.dart';
import 'controllers/book_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mytoken = prefs.getString('authToken');

  // Register controllers
  Get.put(AuthController());
  Get.put(BookController());
  Get.put(ProfileController()); 

  runApp(MyApp(token: mytoken));
}

class MyApp extends StatelessWidget {
  final String? token;
  const MyApp({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: token != null && !JwtDecoder.isExpired(token!)
          ? RoutePages(token: token!)
          : SigninPage(),
    );
  }
}

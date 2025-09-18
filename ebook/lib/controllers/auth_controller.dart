import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // ADD THIS
import 'package:ebook/config.dart';
import 'package:ebook/models/user_model.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  //login function
  Future<Map<String, dynamic>> signinController(UserModel user) async {
    var reqBody = {"email": user.email, "password": user.password};
    var response = await http.post(
      Uri.parse(login),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(reqBody),
    );
    var jsonResponse = jsonDecode(response.body);

    if (jsonResponse['status'] == true) {
      var myToken = jsonResponse['token'];
      
      // ADD THIS - Save token to SharedPreferences
      await _saveToken(myToken);
      print("✅ Token saved after login");
      
      return {
        "status": true,
        "success": "User logged in successfully", // Fixed the message
        "token": myToken,
      };
    } else {
      return {
        "status": false,
        "error": jsonResponse['error'] ?? "Login Failed", // Fixed field name
      };
    }
  }

  // ADD THIS HELPER METHOD
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  //Register function (keep unchanged)
  Future<Map<String, dynamic>> signupController(UserModel user) async {
    var response = await http.post(
      Uri.parse(register),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );
    var jsonResponse = jsonDecode(response.body);

    if (jsonResponse['status'] == true) {
      return {"status": true, "success": "User Registered Successfully"};
    } else {
      return {
        "status": false,
        "error": jsonResponse['error'] ?? "Registration Failed", // Fixed field name
      };
    }
  }
}
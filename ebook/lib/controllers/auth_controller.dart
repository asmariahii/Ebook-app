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

  // ADD THESE METHODS TO YOUR EXISTING AuthController CLASS

// Get current user profile
Future<Map<String, dynamic>> getProfile() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    
    if (token == null) {
      return {"status": false, "error": "No token found. Please login first."};
    }

    var response = await http.get(
      Uri.parse(profileUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    
    var jsonResponse = jsonDecode(response.body);
    
    if (jsonResponse['status'] == true) {
      // Save updated profile data
      await _saveUserProfile(jsonResponse['data']);
      return {
        "status": true,
        "data": jsonResponse['data'],
        "message": jsonResponse['message'] ?? "Profile fetched successfully",
      };
    } else {
      return {
        "status": false,
        "error": jsonResponse['error'] ?? "Failed to fetch profile",
      };
    }
  } catch (e) {
    return {"status": false, "error": "Network error: $e"};
  }
}

// Update profile
Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updateData) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    
    if (token == null) {
      return {"status": false, "error": "No token found. Please login first."};
    }

    var response = await http.put(
      Uri.parse(updateProfileUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(updateData),
    );
    
    var jsonResponse = jsonDecode(response.body);
    
    if (jsonResponse['status'] == true) {
      // Update token if new one is provided
      if (jsonResponse['data']['token'] != null) {
        await _saveToken(jsonResponse['data']['token']);
      }
      // Update profile data
      await _saveUserProfile(jsonResponse['data']['user']);
      return {
        "status": true,
        "success": jsonResponse['success'] ?? "Profile updated successfully",
        "data": jsonResponse['data'],
      };
    } else {
      return {
        "status": false,
        "error": jsonResponse['error'] ?? "Failed to update profile",
      };
    }
  } catch (e) {
    return {"status": false, "error": "Network error: $e"};
  }
}

// ADD THESE HELPER METHODS
Future<void> _saveUserProfile(Map<String, dynamic> profileData) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userProfile', jsonEncode(profileData));
}

Future<Map<String, dynamic>?> getSavedProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final profileString = prefs.getString('userProfile');
  if (profileString != null) {
    return jsonDecode(profileString);
  }
  return null;
}

Future<void> clearUserData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('authToken');
  await prefs.remove('userProfile');
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
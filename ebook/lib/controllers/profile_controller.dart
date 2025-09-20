import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();
  
  final AuthController _authController = AuthController.instance;
  
  // Observables
  final isLoading = false.obs;
  final Rx<Map<String, dynamic>?> userProfile = Rx<Map<String, dynamic>?>(null);
  final errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }
  
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await _authController.getProfile();
      
      if (result['status'] == true) {
        userProfile.value = result['data'];
      } else {
        errorMessage.value = result['error'] ?? 'Failed to load profile';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> updateProfileName(String newName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await _authController.updateProfile({
        "name": newName,
      });
      
      if (result['status'] == true) {
        // Reload profile to show updated data
        await loadProfile();
        Get.snackbar(
          "Success",
          "Profile updated successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        errorMessage.value = result['error'] ?? 'Failed to update profile';
        Get.snackbar(
          "Error",
          errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      Get.snackbar(
        "Error",
        "Something went wrong",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> updateProfilePassword(String currentPassword, String newPassword) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await _authController.updateProfile({
        "currentPassword": currentPassword,
        "newPassword": newPassword,
      });
      
      if (result['status'] == true) {
        // Reload profile
        await loadProfile();
        Get.snackbar(
          "Success",
          "Password updated successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        errorMessage.value = result['error'] ?? 'Failed to update password';
        Get.snackbar(
          "Error",
          errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      Get.snackbar(
        "Error",
        "Something went wrong",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
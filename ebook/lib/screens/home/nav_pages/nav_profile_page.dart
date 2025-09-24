import 'dart:math' as math;

import 'package:ebook/controllers/auth_controller.dart';
import 'package:ebook/controllers/profile_controller.dart';
import 'package:ebook/screens/login/signin_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ebook/utils/constants/colors.dart';

class NavProfilePage extends StatelessWidget {
  const NavProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();
    final TextEditingController nameController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Soft off-white background
      appBar: AppBar(
        title: Image.asset('images/ebook.png', height: 40, fit: BoxFit.contain),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 63, 110, 62), // Teal icon color
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(
                    255,
                    63,
                    110,
                    62,
                  ).withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.settings,
                color: Color.fromARGB(255, 63, 110, 62),
              ),
              onPressed: () {
                Get.snackbar(
                  'Settings',
                  'Settings coming soon!',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: const Color.fromARGB(255, 63, 110, 62),
                  colorText: Colors.white,
                  borderRadius: 8,
                  margin: const EdgeInsets.all(16),
                );
              },
              tooltip: "Settings",
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Obx(() {
          if (profileController.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(
                        255,
                        63,
                        110,
                        62,
                      ), // Teal progress indicator
                    ),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Loading profile...",
                    style: Theme.of(Get.context!).textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 81, 147, 86),
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (profileController.userProfile.value == null) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 1),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color.fromARGB(
                                255,
                                63,
                                110,
                                62,
                              ).withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
                                  255,
                                  63,
                                  110,
                                  62,
                                ).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            size: 80,
                            color: Color.fromARGB(255, 63, 110, 62),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          profileController.errorMessage.value.isEmpty
                              ? 'No profile data'
                              : profileController.errorMessage.value,
                          style: Theme.of(Get.context!).textTheme.headlineSmall
                              ?.copyWith(
                                color: const Color.fromARGB(255, 81, 147, 86),
                                fontSize: 18,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
                                  255,
                                  63,
                                  110,
                                  62,
                                ).withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => profileController.loadProfile(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                63,
                                110,
                                62,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Retry',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          final profile = profileController.userProfile.value!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color.fromARGB(
                                  255,
                                  63,
                                  110,
                                  62,
                                ).withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(
                                    255,
                                    63,
                                    110,
                                    62,
                                  ).withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.transparent,
                              backgroundImage: profile['profilePicture'] != null
                                  ? NetworkImage(
                                      'http://192.168.1.21:5000${profile['profilePicture']}',
                                    )
                                  : null,
                              child: profile['profilePicture'] == null
                                  ? Container(
                                      width: 120,
                                      height: 120,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF5F5F5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Color.fromARGB(255, 63, 110, 62),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: -8,
                            right: -8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 63, 110, 62),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 63, 110, 62),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile['name'] ?? 'User',
                        style: Theme.of(Get.context!).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color.fromARGB(255, 81, 147, 86),
                              fontFamily: 'Poppins',
                              fontSize: 24,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile['email'] ?? 'No email',
                        style: Theme.of(Get.context!).textTheme.bodyMedium
                            ?.copyWith(
                              color: Colors.grey[600],
                              fontFamily: 'Roboto',
                              fontSize: 14,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          255,
                          63,
                          110,
                          62,
                        ).withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            63,
                            110,
                            62,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Personal Information',
                          style: Theme.of(Get.context!).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color.fromARGB(255, 63, 110, 62),
                                fontFamily: 'Poppins',
                              ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildProfileField(
                        context,
                        'Name',
                        profile['name'] ?? 'N/A',
                      ),
                      const SizedBox(height: 16),
                      _buildProfileField(
                        context,
                        'Email',
                        profile['email'] ?? 'N/A',
                      ),
                      const SizedBox(height: 16),
                      _buildProfileField(
                        context,
                        'Member Since',
                        profile['createdAt'] != null
                            ? _formatDate(profile['createdAt'])
                            : 'N/A',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          255,
                          63,
                          110,
                          62,
                        ).withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            63,
                            110,
                            62,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.edit,
                                color: Color.fromARGB(255, 63, 110, 62),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Update Profile',
                                style: Theme.of(Get.context!)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color.fromARGB(
                                        255,
                                        63,
                                        110,
                                        62,
                                      ),
                                      fontFamily: 'Poppins',
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(
                                255,
                                63,
                                110,
                                62,
                              ).withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'New Name',
                            hintText: 'Enter your name',
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: Color.fromARGB(255, 63, 110, 62),
                            ),
                            labelStyle: TextStyle(
                              color: Color.fromARGB(255, 81, 147, 86),
                              fontFamily: 'Roboto',
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(
                                255,
                                63,
                                110,
                                62,
                              ).withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final newName = nameController.text.trim();
                              if (newName.isNotEmpty &&
                                  newName != profile['name']) {
                                profileController.updateProfileName(newName);
                                Get.snackbar(
                                  'Success',
                                  'Name updated successfully',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    63,
                                    110,
                                    62,
                                  ),
                                  colorText: Colors.white,
                                  borderRadius: 8,
                                  margin: const EdgeInsets.all(16),
                                );
                              } else {
                                Get.snackbar(
                                  'Error',
                                  'Please enter a valid name',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    63,
                                    110,
                                    62,
                                  ),
                                  colorText: Colors.white,
                                  borderRadius: 8,
                                  margin: const EdgeInsets.all(16),
                                );
                              }
                            },
                            icon: const Icon(Icons.person, color: Colors.white),
                            label: const Text(
                              'Update Name',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                63,
                                110,
                                62,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(
                                255,
                                63,
                                110,
                                62,
                              ).withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showPasswordUpdateDialog(profileController);
                            },
                            icon: const Icon(
                              Icons.security,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Change Password',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                63,
                                110,
                                62,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          255,
                          63,
                          110,
                          62,
                        ).withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showLogoutDialog(),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 63, 110, 62),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Logout',
                                    style: Theme.of(Get.context!)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: const Color.fromARGB(
                                            255,
                                            63,
                                            110,
                                            62,
                                          ),
                                          fontFamily: 'Poppins',
                                        ),
                                  ),
                                  Text(
                                    'Sign out of your account',
                                    style: Theme.of(Get.context!)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: const Color.fromARGB(
                                            255,
                                            81,
                                            147,
                                            86,
                                          ),
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Color.fromARGB(255, 63, 110, 62),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProfileField(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 63, 110, 62).withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '$label:',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color.fromARGB(255, 63, 110, 62),
                  fontFamily: 'Roboto',
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                color: Colors.black87,
                fontFamily: 'Roboto',
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date is String) {
      try {
        return DateTime.parse(date).toString().split(' ')[0];
      } catch (e) {
        return 'Invalid date';
      }
    }
    return date?.toString() ?? 'N/A';
  }

  void _showPasswordUpdateDialog(ProfileController controller) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 63, 110, 62),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.security,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Change Password',
                          style: Theme.of(Get.context!).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          255,
                          63,
                          110,
                          62,
                        ).withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: currentPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Color.fromARGB(255, 63, 110, 62),
                      ),
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 81, 147, 86),
                        fontFamily: 'Roboto',
                      ),
                    ),
                    style: const TextStyle(fontSize: 16, fontFamily: 'Roboto'),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          255,
                          63,
                          110,
                          62,
                        ).withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Color.fromARGB(255, 63, 110, 62),
                      ),
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 81, 147, 86),
                        fontFamily: 'Roboto',
                      ),
                    ),
                    style: const TextStyle(fontSize: 16, fontFamily: 'Roboto'),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          255,
                          63,
                          110,
                          62,
                        ).withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Color.fromARGB(255, 63, 110, 62),
                      ),
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 81, 147, 86),
                        fontFamily: 'Roboto',
                      ),
                    ),
                    style: const TextStyle(fontSize: 16, fontFamily: 'Roboto'),
                  ),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'Cancel',
                          style: Theme.of(Get.context!).textTheme.bodyMedium
                              ?.copyWith(
                                color: const Color.fromARGB(255, 81, 147, 86),
                                fontFamily: 'Roboto',
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 63, 110, 62),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            final current = currentPasswordController.text
                                .trim();
                            final newPass = newPasswordController.text.trim();
                            final confirm = confirmPasswordController.text
                                .trim();

                            if (newPass.isEmpty || confirm.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Please fill all fields',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  63,
                                  110,
                                  62,
                                ),
                                colorText: Colors.white,
                                borderRadius: 8,
                                margin: const EdgeInsets.all(16),
                              );
                              return;
                            }

                            if (newPass != confirm) {
                              Get.snackbar(
                                'Error',
                                'Passwords do not match',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  63,
                                  110,
                                  62,
                                ),
                                colorText: Colors.white,
                                borderRadius: 8,
                                margin: const EdgeInsets.all(16),
                              );
                              return;
                            }

                            if (newPass.length < 6) {
                              Get.snackbar(
                                'Error',
                                'Password must be at least 6 characters',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  63,
                                  110,
                                  62,
                                ),
                                colorText: Colors.white,
                                borderRadius: 8,
                                margin: const EdgeInsets.all(16),
                              );
                              return;
                            }

                            controller.updateProfilePassword(current, newPass);
                            Get.back();
                            Get.snackbar(
                              'Success',
                              'Password updated successfully',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: const Color.fromARGB(
                                255,
                                63,
                                110,
                                62,
                              ),
                              colorText: Colors.white,
                              borderRadius: 8,
                              margin: const EdgeInsets.all(16),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Update',
                            style: Theme.of(Get.context!).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxWidth: 400, // Constrain dialog width
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 63, 110, 62),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.logout, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: Theme.of(Get.context!).textTheme.titleLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      63,
                      110,
                      62,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Are you sure you want to logout? This will end your current session.',
                    style: Theme.of(Get.context!).textTheme.bodyMedium
                        ?.copyWith(
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          color: Colors.black87,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Cancel',
                        style: Theme.of(Get.context!).textTheme.bodyMedium
                            ?.copyWith(
                              color: const Color.fromARGB(255, 81, 147, 86),
                              fontFamily: 'Roboto',
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 63, 110, 62),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () async {
                          Get.back(); // Close dialog
                          try {
                            final result = await Get.find<AuthController>()
                                .logout();
                            if (result['status'] == true) {
                              // Replace all routes with SigninPage
                              Navigator.of(Get.context!).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const SigninPage(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                              Get.snackbar(
                                'Success',
                                result['success'],
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  63,
                                  110,
                                  62,
                                ),
                                colorText: Colors.white,
                                borderRadius: 8,
                                margin: const EdgeInsets.all(16),
                              );
                            } else {
                              Get.snackbar(
                                'Error',
                                result['error'],
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  63,
                                  110,
                                  62,
                                ),
                                colorText: Colors.white,
                                borderRadius: 8,
                                margin: const EdgeInsets.all(16),
                              );
                            }
                          } catch (e) {
                            print('Logout error: $e');
                            Get.snackbar(
                              'Error',
                              'Error during logout: $e',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: const Color.fromARGB(
                                255,
                                63,
                                110,
                                62,
                              ),
                              colorText: Colors.white,
                              borderRadius: 8,
                              margin: const EdgeInsets.all(16),
                            );
                          }
                        },
                        child: Text(
                          'Logout',
                          style: Theme.of(Get.context!).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

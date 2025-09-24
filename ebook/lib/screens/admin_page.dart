import 'package:ebook/controllers/auth_controller.dart';
import 'package:ebook/config.dart';
import 'package:ebook/controllers/book_controller.dart';
import 'package:ebook/screens/home/analytics_management_page.dart';
import 'package:ebook/screens/home/book_management_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<dynamic> users = [];
  bool isLoading = true;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Helper method to safely update state
  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  // Analytics Management
  Widget _buildAnalyticsManagement() {
    return const AnalyticsManagementPage();
  }

  // Fetch all users from backend
  Future<void> fetchUsers() async {
    try {
      _safeSetState(() => isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null) {
        Get.snackbar(
          'Error',
          'No authentication token found',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color.fromARGB(255, 60, 120, 68),
          colorText: Colors.white,
          borderRadius: 8,
          margin: const EdgeInsets.all(16),
        );
        _safeSetState(() => isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse(adminUsersUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final regularUsers = (data['data'] ?? [])
            .where((user) => user['role'] != 'admin')
            .toList();

        _safeSetState(() {
          users = regularUsers;
          isLoading = false;
        });
      } else {
        _safeSetState(() => isLoading = false);
        Get.snackbar(
          'Error',
          'Failed to load users: ${response.statusCode}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color.fromARGB(255, 60, 120, 68),
          colorText: Colors.white,
          borderRadius: 8,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      _safeSetState(() => isLoading = false);
      Get.snackbar(
        'Error',
        'Network error: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color.fromARGB(255, 60, 120, 68),
        colorText: Colors.white,
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null) {
        Get.snackbar(
          'Error',
          'No authentication token found',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color.fromARGB(255, 60, 120, 68),
          colorText: Colors.white,
          borderRadius: 8,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      final response = await http.delete(
        Uri.parse('$adminDeleteUserUrl/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _safeSetState(() {
          users.removeWhere((user) => user['_id'] == userId);
        });
        Get.snackbar(
          'Success',
          'User deleted successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color.fromARGB(255, 60, 120, 68),
          colorText: Colors.white,
          borderRadius: 8,
          margin: const EdgeInsets.all(16),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete user: ${response.statusCode}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color.fromARGB(255, 60, 120, 68),
          colorText: Colors.white,
          borderRadius: 8,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color.fromARGB(255, 60, 120, 68),
        colorText: Colors.white,
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  // User Management
  Widget _buildUserManagement() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 79, 156, 89),
              ),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading users...',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 94, 184, 100),
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 79, 156, 89).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.people_outline,
                size: 80,
                color: Color.fromARGB(255, 94, 184, 100),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 94, 184, 100),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 79, 156, 89).withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: fetchUsers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 79, 156, 89),
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
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Color.fromARGB(255, 200, 230, 201)),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Color.fromARGB(255, 200, 230, 201),
              radius: 24,
              child: Text(
                user['name']?[0].toUpperCase() ?? 'U',
                style: TextStyle(
                  color: Color.fromARGB(255, 60, 120, 68),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            title: Text(
              user['name'] ?? 'Unknown User',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                fontSize: 16,
              ),
            ),
            subtitle: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['email'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Role: ${user['role']?.toUpperCase() ?? 'USER'}',
                    style: TextStyle(
                      color: Color.fromARGB(255, 94, 184, 100),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  Text(
                    'Joined: ${DateTime.tryParse(user['createdAt'] ?? '')?.toString().split(' ')[0] ?? 'Unknown'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            trailing: PopupMenuButton(
              onSelected: (value) {
                if (value == 'delete') {
                  Get.dialog(
                    Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 79, 156, 89),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Delete User',
                                      style: Theme.of(Get.context!)
                                          .textTheme
                                          .titleLarge
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
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  'Are you sure you want to delete ${user['name']}?',
                                  style: Theme.of(Get.context!)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontSize: 16,
                                        fontFamily: 'Roboto',
                                        color: Colors.black87,
                                      ),
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
                                        style: Theme.of(Get.context!)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Color.fromARGB(
                                                255,
                                                94,
                                                184,
                                                100,
                                              ),
                                              fontFamily: 'Roboto',
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Get.back();
                                          deleteUser(user['_id']);
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
                                          'Delete',
                                          style: Theme.of(Get.context!)
                                              .textTheme
                                              .bodyLarge
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
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red, fontFamily: 'Roboto'),
                  ),
                ),
              ],
            ),
            onTap: () {
              Get.snackbar(
                'User Info',
                'Name: ${user['name']}\nEmail: ${user['email']}\nRole: ${user['role']}',
                duration: const Duration(seconds: 3),
                snackPosition: SnackPosition.TOP,
                backgroundColor: Color.fromARGB(255, 60, 120, 68),
                colorText: Colors.white,
                borderRadius: 8,
                margin: const EdgeInsets.all(16),
              );
            },
          ),
        );
      },
    );
  }

  // Book Management
  Widget _buildBookManagement() {
    return BookManagementPage();
  }

  // Sidebar
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 60, 120, 68),
                  Color.fromARGB(255, 79, 156, 89),
                ],
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(
                            255,
                            79,
                            156,
                            89,
                          ).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.admin_panel_settings,
                        size: 35,
                        color: Color.fromARGB(255, 94, 184, 100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    'Welcome Admin',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.people,
              color: Color.fromARGB(255, 94, 184, 100),
            ),
            title: Text(
              'User Management',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: currentIndex == 0,
            selectedTileColor: Color.fromARGB(255, 200, 230, 201),
            onTap: () {
              setState(() => currentIndex = 0);
              Get.back();
            },
            trailing: currentIndex == 0
                ? Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 79, 156, 89),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                : null,
          ),
          ListTile(
            leading: Icon(Icons.book, color: Color.fromARGB(255, 94, 184, 100)),
            title: Text(
              'Book Management',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: currentIndex == 1,
            selectedTileColor: Color.fromARGB(255, 200, 230, 201),
            onTap: () {
              setState(() => currentIndex = 1);
              Get.back();
            },
            trailing: currentIndex == 1
                ? Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 79, 156, 89),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                : null,
          ),
          const Divider(color: Color.fromARGB(255, 200, 230, 201)),
          ListTile(
            leading: Icon(
              Icons.analytics,
              color: Color.fromARGB(255, 94, 184, 100),
            ),
            title: Text(
              'Analytics',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: currentIndex == 2,
            selectedTileColor: Color.fromARGB(255, 200, 230, 201),
            onTap: () {
              setState(() => currentIndex = 2);
              Get.back();
            },
            trailing: currentIndex == 2
                ? Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 79, 156, 89),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                : null,
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: Color.fromARGB(255, 94, 184, 100),
            ),
            title: Text(
              'Settings',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: currentIndex == 3,
            selectedTileColor: Color.fromARGB(255, 200, 230, 201),
            onTap: () {
              setState(() => currentIndex = 3);
              Get.back();
              Get.toNamed('/profile');
            },
            trailing: currentIndex == 3
                ? Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 79, 156, 89),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                : null,
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              await Get.find<AuthController>().clearUserData();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  // Bottom navigation
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 79, 156, 89).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (mounted) {
            setState(() => currentIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color.fromARGB(255, 79, 156, 89),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Books'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    switch (currentIndex) {
      case 0:
        currentPage = _buildUserManagement();
        break;
      case 1:
        currentPage = _buildBookManagement();
        break;
      case 2:
        currentPage = _buildAnalyticsManagement(); // Ensure this is used
        break;
      case 3:
        currentPage = Center(
          child: Text(
            'Settings Page - Coming Soon',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Poppins',
              color: Color.fromARGB(255, 94, 184, 100),
            ),
          ),
        );
        break;
      default:
        currentPage = _buildUserManagement();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/ebook.png', height: 40, fit: BoxFit.contain),
              const SizedBox(width: 8),
              Text(
                [
                  'User Management',
                  'Book Management',
                  'Analytics',
                  'Settings',
                ][currentIndex],
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Color.fromARGB(255, 79, 156, 89).withOpacity(0.2),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 79, 156, 89)),
        actions: [
          if (currentIndex == 0)
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Color.fromARGB(255, 79, 156, 89),
              ),
              onPressed: fetchUsers,
              tooltip: 'Refresh Users',
            ),
          if (currentIndex == 2)
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Color.fromARGB(255, 79, 156, 89),
              ),
              onPressed: () => Get.find<BookController>().fetchAnalytics(),
              tooltip: 'Refresh Analytics',
            ),
        ],
      ),
      drawer: _buildDrawer(),
      body: currentPage,
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              onPressed: fetchUsers,
              backgroundColor: Color.fromARGB(255, 79, 156, 89),
              child: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Refresh Users',
            )
          : null,
    );
  }
}

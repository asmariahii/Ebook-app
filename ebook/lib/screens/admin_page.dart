import 'package:ebook/controllers/auth_controller.dart';
import 'package:ebook/config.dart';
import 'package:ebook/screens/home/book_management_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AdminDashboard extends StatefulWidget {
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
    // Cancel any ongoing operations here if needed
  }

  // Helper method to safely update state
  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  // Fetch all users from backend (with mounted check)
  Future<void> fetchUsers() async {
    try {
      _safeSetState(() => isLoading = true);
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      
      if (token == null) {
        Get.snackbar('Error', 'No authentication token found');
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
        // Filter out admin users - show only regular users
        final regularUsers = (data['data'] ?? [])
            .where((user) => user['role'] != 'admin')
            .toList();
        
        _safeSetState(() {
          users = regularUsers;
          isLoading = false;
        });
      } else {
        _safeSetState(() => isLoading = false);
        Get.snackbar('Error', 'Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      _safeSetState(() => isLoading = false);
      Get.snackbar('Error', 'Network error: $e');
    }
  }

  // Delete user (with mounted check)
  Future<void> deleteUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      
      if (token == null) {
        Get.snackbar('Error', 'No authentication token found');
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
        Get.snackbar('Success', 'User deleted successfully');
      } else {
        Get.snackbar('Error', 'Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Network error: $e');
    }
  }

  // Sidebar pages
  Widget _buildUserManagement() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 100, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Text(
                user['name']?[0].toUpperCase() ?? 'U',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              user['name'] ?? 'Unknown User',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['email'] ?? ''),
                Text(
                  'Role: ${user['role']?.toUpperCase() ?? 'USER'}',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Joined: ${DateTime.tryParse(user['createdAt'] ?? '')?.toString().split(' ')[0] ?? 'Unknown'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              onSelected: (value) {
                if (value == 'delete') {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Delete User'),
                      content: Text('Are you sure you want to delete ${user['name']}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            deleteUser(user['_id']);
                          },
                          child: Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
            onTap: () {
              Get.snackbar(
                'User Info',
                'Name: ${user['name']}\nEmail: ${user['email']}\nRole: ${user['role']}',
                duration: Duration(seconds: 3),
              );
            },
          ),
        );
      },
    );
  }

  // In your admin_page.dart, replace the _buildBookManagement method:
Widget _buildBookManagement() {
  return BookManagementPage(); // Use the new page
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
                colors: [Colors.blue.shade700, Colors.blue.shade500],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.admin_panel_settings, size: 35, color: Colors.blue),
                ),
                SizedBox(height: 10),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Welcome Admin',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('User Management'),
            selected: currentIndex == 0,
            selectedTileColor: Colors.blue.shade50,
            onTap: () {
              setState(() => currentIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('Book Management'),
            selected: currentIndex == 1,
            selectedTileColor: Colors.blue.shade50,
            onTap: () {
              setState(() => currentIndex = 1);
              Navigator.pop(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Analytics'),
            selected: currentIndex == 2,
            selectedTileColor: Colors.blue.shade50,
            onTap: () {
              setState(() => currentIndex = 2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            selected: currentIndex == 3,
            selectedTileColor: Colors.blue.shade50,
            onTap: () {
              setState(() => currentIndex = 3);
              Navigator.pop(context);
            },
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
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
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (mounted) {
          setState(() => currentIndex = index);
        }
      },
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Books',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
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
        currentPage = Center(child: Text('Analytics Page - Coming Soon'));
        break;
      case 3:
        currentPage = Center(child: Text('Settings Page - Coming Soon'));
        break;
      default:
        currentPage = _buildUserManagement();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(['User Management', 'Book Management', 'Analytics', 'Settings'][currentIndex]),
        backgroundColor: Colors.blue,
        actions: [
          if (currentIndex == 0)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: fetchUsers,
            ),
        ],
      ),
      drawer: _buildDrawer(),
      body: currentPage,
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              onPressed: fetchUsers,
              child: Icon(Icons.refresh),
              tooltip: 'Refresh Users',
            )
          : null,
    );
  }
}
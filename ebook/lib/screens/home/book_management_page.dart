import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ebook/config.dart';
import 'package:ebook/models/book_model.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;

class BookManagementPage extends StatefulWidget {
  @override
  _BookManagementPageState createState() => _BookManagementPageState();
}

class _BookManagementPageState extends State<BookManagementPage> {
  List<BookModel> books = [];
  bool isLoading = true;
  bool isAddingBook = false;

  // File upload variables
  bool isUploading = false;
  dynamic selectedCoverImage;
  dynamic selectedPdfFile;
  Uint8List? coverImageBytes;
  Uint8List? pdfFileBytes;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  // Helper method to safely update state
  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  // Fetch all books from backend
  Future<void> fetchBooks() async {
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
        Uri.parse(adminBooksUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bookList = (data['data'] ?? [])
            .map<BookModel>((json) => BookModel.fromJson(json))
            .toList();

        _safeSetState(() {
          books = bookList;
          isLoading = false;
        });
      } else {
        _safeSetState(() => isLoading = false);
        Get.snackbar('Error', 'Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      _safeSetState(() => isLoading = false);
      Get.snackbar('Error', 'Network error: $e');
    }
  }

  // Add new book with file uploads
  Future<void> addBook({
    required String title,
    required String author,
    required String description,
    dynamic coverFile,
    dynamic pdfFile,
    bool isTrending = false,
  }) async {
    try {
      _safeSetState(() => isAddingBook = true);
      setState(() => isUploading = true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null) {
        Get.snackbar('Error', 'No authentication token found');
        _safeSetState(() => isAddingBook = false);
        setState(() => isUploading = false);
        return;
      }

      // Validate file selections
      if (coverFile == null) {
        Get.snackbar('Error', 'Please select a cover image');
        _safeSetState(() => isAddingBook = false);
        setState(() => isUploading = false);
        return;
      }

      if (pdfFile == null) {
        Get.snackbar('Error', 'Please select a PDF file');
        _safeSetState(() => isAddingBook = false);
        setState(() => isUploading = false);
        return;
      }

      // Upload cover image
      String? coverUrl = await _uploadCoverImage(coverFile, token);
      if (coverUrl == null) {
        _safeSetState(() => isAddingBook = false);
        setState(() => isUploading = false);
        return;
      }

      // Upload PDF file
      String? pdfUrl = await _uploadPdfFile(pdfFile, token);
      if (pdfUrl == null) {
        _safeSetState(() => isAddingBook = false);
        setState(() => isUploading = false);
        return;
      }

      // Create book with uploaded URLs
      final response = await http.post(
        Uri.parse(adminAddBookUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'author': author,
          'description': description,
          'cover': coverUrl,
          'file': pdfUrl,
          'isTrending': isTrending,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newBook = BookModel.fromJson(data['data']);

        _safeSetState(() {
          books.insert(0, newBook);
          isAddingBook = false;
        });

        Get.snackbar(
          'Success',
          'Book "${newBook.title}" added successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Clear the form
        _clearForm();
      } else {
        _safeSetState(() => isAddingBook = false);
        final errorData = jsonDecode(response.body);
        Get.snackbar('Error', errorData['error'] ?? 'Failed to add book');
      }
    } catch (e) {
      _safeSetState(() => isAddingBook = false);
      setState(() => isUploading = false);
      Get.snackbar('Error', 'Network error: $e');
    } finally {
      setState(() => isUploading = false);
    }
  }

  // Delete book
  Future<void> deleteBook(String bookId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null) {
        Get.snackbar('Error', 'No authentication token found');
        return;
      }

      final response = await http.delete(
        Uri.parse('$adminDeleteBookUrl/$bookId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _safeSetState(() {
          books.removeWhere((book) => book.id == bookId);
        });
        Get.snackbar(
          'Success',
          'Book deleted successfully!',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Error', 'Failed to delete book');
      }
    } catch (e) {
      Get.snackbar('Error', 'Network error: $e');
    }
  }

  // Upload cover image
  Future<String?> _uploadCoverImage(dynamic imageFile, String token) async {
    try {
      print("🖼️ Uploading cover image: ${kIsWeb ? imageFile.name : imageFile.path}");

      var request = http.MultipartRequest('POST', Uri.parse(uploadCoverUrl));
      request.headers.addAll({
        "Authorization": "Bearer $token",
      });

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'cover',
            coverImageBytes!,
            filename: imageFile.name,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'cover',
            imageFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      print("📡 Cover upload response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseString);
        if (jsonResponse['status'] == true) {
          final imageUrl = jsonResponse['data']['url'] ?? jsonResponse['url'];
          print("✅ Cover uploaded: $imageUrl");
          return imageUrl;
        } else {
          print("❌ Server error: ${jsonResponse['error']}");
          Get.snackbar('Upload Error', jsonResponse['error'] ?? 'Failed to upload cover');
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
        final errorData = jsonDecode(responseString);
        Get.snackbar('Upload Error', errorData['error'] ?? 'Failed to upload cover');
      }
    } catch (e) {
      print("❌ Error uploading cover: $e");
      Get.snackbar('Upload Error', 'Network error: $e');
    }
    return null;
  }

  // Upload PDF file
  Future<String?> _uploadPdfFile(dynamic pdfFile, String token) async {
    try {
      print("📄 Uploading PDF: ${kIsWeb ? pdfFile.name : pdfFile.path}");

      var request = http.MultipartRequest('POST', Uri.parse(uploadPdfUrl));
      request.headers.addAll({
        "Authorization": "Bearer $token",
      });

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'pdf',
            pdfFileBytes!,
            filename: pdfFile.name,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'pdf',
            pdfFile.path,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      }

      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      print("📡 PDF upload response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseString);
        if (jsonResponse['status'] == true) {
          final pdfUrl = jsonResponse['data']['url'] ?? jsonResponse['url'];
          print("✅ PDF uploaded: $pdfUrl");
          return pdfUrl;
        } else {
          print("❌ Server error: ${jsonResponse['error']}");
          Get.snackbar('Upload Error', jsonResponse['error'] ?? 'Failed to upload PDF');
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
        final errorData = jsonDecode(responseString);
        Get.snackbar('Upload Error', errorData['error'] ?? 'Failed to upload PDF');
      }
    } catch (e) {
      print("❌ Error uploading PDF: $e");
      Get.snackbar('Upload Error', 'Network error: $e');
    }
    return null;
  }

  // Show add book dialog
  void _showAddBookDialog() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isTrending = false;

    // Clear previous selections
    selectedCoverImage = null;
    selectedPdfFile = null;
    coverImageBytes = null;
    pdfFileBytes = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.hd, color: Colors.green),
              SizedBox(width: 8),
              Text('Add New Book'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 550,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Book Title *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title is required';
                        }
                        if (value.length < 3) {
                          return 'Title must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Author
                    TextFormField(
                      controller: authorController,
                      decoration: InputDecoration(
                        labelText: 'Author *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Author is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Description is required';
                        }
                        if (value.length < 10) {
                          return 'Description must be at least 10 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Cover Image Upload
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.image, color: Colors.blue.shade700),
                              SizedBox(width: 8),
                              Text(
                                'Cover Image *',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: isUploading || isAddingBook
                                ? null
                                : () async {
                                    try {
                                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                                        type: FileType.image,
                                        allowMultiple: false,
                                      );

                                      if (result != null && (result.files.single.path != null || result.files.single.bytes != null)) {
                                        setDialogState(() {
                                          if (kIsWeb) {
                                            selectedCoverImage = result.files.single;
                                            coverImageBytes = result.files.single.bytes;
                                          } else {
                                            selectedCoverImage = File(result.files.single.path!);
                                          }
                                        });
                                        Get.snackbar(
                                          'Image Selected',
                                          '${result.files.single.name}',
                                          backgroundColor: Colors.blue,
                                          duration: const Duration(seconds: 2),
                                        );
                                      }
                                    } catch (e) {
                                      print("❌ Image picker error: $e");
                                      Get.snackbar(
                                        'Error',
                                        'Failed to pick image: $e',
                                        backgroundColor: Colors.red,
                                      );
                                    }
                                  },
                            icon: Icon(Icons.photo_library),
                            label: Text(
                              selectedCoverImage != null
                                  ? '✅ ${kIsWeb ? selectedCoverImage.name : selectedCoverImage.path.split('/').last}'
                                  : 'Select Cover Image',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 48),
                            ),
                          ),
                          if (selectedCoverImage != null) ...[
                            SizedBox(height: 12),
                            Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 56,
                                    color: Colors.blue.shade400,
                                  ),
                                  SizedBox(height: 12),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      kIsWeb ? selectedCoverImage.name : selectedCoverImage.path.split('/').last,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Ready to upload',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // PDF File Upload
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.picture_as_pdf, color: Colors.red.shade700),
                              SizedBox(width: 8),
                              Text(
                                'PDF File *',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: isUploading || isAddingBook
                                ? null
                                : () async {
                                    try {
                                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['pdf'],
                                      );

                                      if (result != null && (result.files.single.path != null || result.files.single.bytes != null)) {
                                        setDialogState(() {
                                          if (kIsWeb) {
                                            selectedPdfFile = result.files.single;
                                            pdfFileBytes = result.files.single.bytes;
                                          } else {
                                            selectedPdfFile = File(result.files.single.path!);
                                          }
                                        });
                                        Get.snackbar(
                                          'PDF Selected',
                                          '${result.files.single.name}',
                                          backgroundColor: Colors.red.shade400,
                                          duration: const Duration(seconds: 2),
                                        );
                                      }
                                    } catch (e) {
                                      print("❌ PDF picker error: $e");
                                      Get.snackbar(
                                        'Error',
                                        'Failed to pick PDF: $e',
                                        backgroundColor: Colors.red,
                                      );
                                    }
                                  },
                            icon: Icon(Icons.picture_as_pdf),
                            label: Text(
                              selectedPdfFile != null
                                  ? '✅ ${kIsWeb ? selectedPdfFile.name : selectedPdfFile.path.split('/').last}'
                                  : 'Select PDF File',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 48),
                            ),
                          ),
                          if (selectedPdfFile != null) ...[
                            SizedBox(height: 12),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade300),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.red.shade600,
                                    size: 40,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          kIsWeb ? selectedPdfFile.name : selectedPdfFile.path.split('/').last,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red.shade800,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'PDF file ready to upload',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Trending checkbox
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isTrending,
                            onChanged: isUploading || isAddingBook
                                ? null
                                : (value) => setDialogState(() => isTrending = value ?? false),
                          ),
                          Icon(Icons.trending_up, color: Colors.orange.shade700, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Mark as Trending Book',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearForm();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isAddingBook || isUploading ||
                      selectedCoverImage == null || selectedPdfFile == null
                  ? null
                  : () async {
                      if (formKey.currentState!.validate() &&
                          selectedCoverImage != null &&
                          selectedPdfFile != null) {
                        // Show confirmation
                        final confirmed = await Get.dialog<bool>(
                          AlertDialog(
                            title: Text('Confirm Add Book'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Book Details:', style: TextStyle(fontWeight: FontWeight.w600)),
                                SizedBox(height: 8),
                                Text('• Title: ${titleController.text}'),
                                Text('• Author: ${authorController.text}'),
                                Text(
                                    '• Cover: ${kIsWeb ? selectedCoverImage.name : selectedCoverImage.path.split('/').last}'),
                                Text(
                                    '• PDF: ${kIsWeb ? selectedPdfFile.name : selectedPdfFile.path.split('/').last}'),
                                if (isTrending) Text('• Trending: Yes'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Get.back(result: true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: Text('Confirm'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          Navigator.pop(context);
                          await addBook(
                            title: titleController.text.trim(),
                            author: authorController.text.trim(),
                            description: descriptionController.text.trim(),
                            coverFile: selectedCoverImage,
                            pdfFile: selectedPdfFile,
                            isTrending: isTrending,
                          );

                          // Clear controllers
                          titleController.dispose();
                          authorController.dispose();
                          descriptionController.dispose();
                        }
                      } else {
                        Get.snackbar(
                          'Validation Error',
                          'Please fill all fields and select both files',
                          backgroundColor: Colors.orange,
                          duration: const Duration(seconds: 3),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: isAddingBook || isUploading
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Adding...'),
                      ],
                    )
                  : Text('Add Book'),
            ),
          ],
        ),
      ),
    );
  }

  void _clearForm() {
    selectedCoverImage = null;
    selectedPdfFile = null;
    coverImageBytes = null;
    pdfFileBytes = null;
    setState(() {});
  }

  // Helper method to show book details snackbar
  void _showBookDetailsSnackbar(BookModel book) {
    String details = 'Author: ${book.author}\n';
    details += book.description?.isNotEmpty == true
        ? 'Description: ${book.description!.length > 80 ? book.description!.substring(0, 80) + '...' : book.description}'
        : 'Description: No description available';

    if (book.isTrending == true) {
      details += '\n\n🔥 Trending Book';
    }

    Get.snackbar(
      book.title,
      details,
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade50,
      colorText: Colors.blue.shade800,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildBookList() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text('Loading books...', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 100, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No books found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: fetchBooks,
              icon: Icon(Icons.refresh),
              label: Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: book.cover != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        book.cover!,
                        fit: BoxFit.cover,
                        width: 60,
                        height: 80,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    )
                  : Icon(Icons.book, color: Colors.grey, size: 40),
            ),
            title: Text(
              book.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  book.author,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  book.description ?? 'No description',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                if (book.isTrending == true) ...[
                  SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_up, size: 14, color: Colors.orange.shade700),
                        SizedBox(width: 4),
                        Text(
                          'Trending',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'edit') {
                  Get.snackbar(
                    'Coming Soon',
                    'Edit book functionality will be available soon!',
                    backgroundColor: Colors.blue,
                    duration: const Duration(seconds: 2),
                  );
                } else if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete Book'),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Are you sure you want to delete'),
                          Text(
                            '"${book.title}"',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text('This action cannot be undone.'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await deleteBook(book.id!);
                  }
                } else if (value == 'view') {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(book.title),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Author: ${book.author}'),
                            SizedBox(height: 8),
                            Text('Description:'),
                            SizedBox(height: 4),
                            Text(
                              book.description ?? 'No description available',
                              style: TextStyle(height: 1.4),
                            ),
                            if (book.cover != null) ...[
                              SizedBox(height: 12),
                              Text('Cover:'),
                              SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  book.cover!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Close'),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 18),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => _showBookDetailsSnackbar(book),
          ),
        );
      },
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[50],
    body: _buildBookList(),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _showAddBookDialog,
      icon: Icon(Icons.add),
      label: Text('Add Book'),
      backgroundColor: Colors.green.shade600,
      foregroundColor: Colors.white,
      elevation: 6,
    ),
  );
}
  @override
  void dispose() {
    // Clean up resources safely
    if (!kIsWeb && selectedCoverImage is File) {
      try {
        if ((selectedCoverImage as File).existsSync()) {
          (selectedCoverImage as File).deleteSync();
        }
      } catch (e) {
        print("❌ Error deleting temporary cover image: $e");
      }
    }
    if (!kIsWeb && selectedPdfFile is File) {
      try {
        if ((selectedPdfFile as File).existsSync()) {
          (selectedPdfFile as File).deleteSync();
        }
      } catch (e) {
        print("❌ Error deleting temporary PDF: $e");
      }
    }
    super.dispose();
  }
}
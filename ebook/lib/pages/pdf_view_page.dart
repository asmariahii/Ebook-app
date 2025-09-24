import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;

class PdfViewPage extends StatefulWidget {
  final String url;
  const PdfViewPage({super.key, required this.url});

  @override
  State<PdfViewPage> createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  PdfControllerPinch? _pdfController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode == 200) {
        final doc = PdfDocument.openData(response.bodyBytes);
        setState(() {
          _pdfController = PdfControllerPinch(document: doc);
          _loading = false;
        });
      } else {
        throw Exception('Failed to load PDF');
      }
    } catch (e) {
      print("PDF load error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Error loading PDF"),
            backgroundColor: const Color.fromARGB(255, 63, 110, 62),
          ),
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), // Soft off-white background
        appBar: AppBar(
          title: Image.asset(
            'images/ebook.png',
            height: 40,
            fit: BoxFit.contain,
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          iconTheme: const IconThemeData(
            color: Color.fromARGB(255, 63, 110, 62), // Teal icon color
          ),
        ),
        body: _loading
            ? _buildLoadingState()
            : _pdfController == null
                ? _buildErrorState()
                : PdfViewPinch(
                    controller: _pdfController!,
                    backgroundDecoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA), // Match scaffold background
                    ),
                  ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.fromARGB(255, 63, 110, 62), // Teal progress indicator
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Loading your book...",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color.fromARGB(255, 81, 147, 86), // Deep teal
                  fontFamily: 'Roboto',
                  fontSize: 18,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: Color.fromARGB(255, 63, 110, 62), // Teal error icon
          ),
          const SizedBox(height: 16),
          Text(
            "Failed to load PDF",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color.fromARGB(255, 81, 147, 86), // Deep teal
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please try again later",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontFamily: 'Roboto',
                  fontSize: 16,
                ),
          ),
          const SizedBox(height: 24),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _loadPdf();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 63, 110, 62), // Teal button
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
                shadowColor: const Color.fromARGB(255, 63, 110, 62).withOpacity(0.4),
              ),
              child: const Text(
                "Retry",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
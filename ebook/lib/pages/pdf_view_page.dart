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
          const SnackBar(content: Text("Error loading PDF")),
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Viewer")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pdfController == null
              ? const Center(child: Text("Failed to load PDF"))
              : PdfViewPinch(controller: _pdfController!),
    );
  }
}

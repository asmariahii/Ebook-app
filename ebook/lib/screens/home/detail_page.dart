import 'package:ebook/controllers/book_controller.dart';
import 'package:ebook/models/book_model.dart';
import 'package:ebook/utils/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:get/get.dart';
import '../../pages/pdf_view_page.dart';

class Detailpage extends StatefulWidget {
  const Detailpage({super.key, required this.bookModel});
  final BookModel bookModel;

  @override
  State<Detailpage> createState() => _DetailpageState();
}

class _DetailpageState extends State<Detailpage> {
  final BookController bookController = BookController.instance;

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
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: widget.bookModel.id,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      widget.bookModel.cover,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 300,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.bookModel.author,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color.fromARGB(255, 81, 147, 86), // Deep teal
                        fontSize: 24,
                        fontFamily: 'Poppins',
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.bookModel.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                        fontSize: 18,
                        fontFamily: 'Roboto',
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Heart Button
                    Obx(() {
                      bool isFavorite = bookController.isBookInFavorites(widget.bookModel.id);
                      return _buildIconButton(
                        icon: isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                        color: isFavorite ? Colors.red : const Color.fromARGB(255, 63, 110, 62),
                        onPressed: () async {
                          print("🔥 Heart button pressed for book: ${widget.bookModel.id}");
                          bool success = await bookController.addToFavorites(widget.bookModel.id);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Added to favorites ❤️"),
                                backgroundColor: const Color.fromARGB(255, 63, 110, 62),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Failed to add to favorites"),
                                backgroundColor: const Color.fromARGB(255, 63, 110, 62),
                              ),
                            );
                          }
                        },
                        tooltip: isFavorite ? "Remove from favorites" : "Add to favorites",
                      );
                    }),
                    const SizedBox(width: 16),
                    // PDF Button
                    _buildIconButton(
                      icon: CupertinoIcons.doc_text,
                      color: const Color.fromARGB(255, 63, 110, 62),
                      onPressed: () {
                        if (widget.bookModel.file.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PdfViewPage(
                                url: widget.bookModel.file,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("PDF not available")),
                          );
                        }
                      },
                      tooltip: "View PDF",
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ReadMoreText(
                  widget.bookModel.description,
                  trimMode: TrimMode.Line,
                  trimLines: 4,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[800],
                        fontSize: 16,
                        fontFamily: 'Roboto',
                      ),
                  colorClickableText: const Color.fromARGB(255, 63, 110, 62),
                  trimCollapsedText: 'Show more',
                  trimExpandedText: 'Show less',
                  moreStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color.fromARGB(255, 63, 110, 62),
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 28),
        tooltip: tooltip,
      ),
    );
  }
}
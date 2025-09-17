import 'package:ebook/models/book_model.dart';
import 'package:flutter/material.dart';

class TrendingWidget extends StatelessWidget {
  const TrendingWidget({super.key, required this.bookModel});
  final BookModel bookModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      height: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              bookModel.cover, // Full URL from backend
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 80),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            bookModel.author,
            style: Theme.of(context).textTheme.headlineMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            bookModel.title,
            style: Theme.of(context).textTheme.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

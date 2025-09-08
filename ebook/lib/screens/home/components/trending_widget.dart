import 'package:ebook/models/book_model.dart';
import 'package:flutter/material.dart';

class TrendingWidget extends StatelessWidget {
  const TrendingWidget({super.key, required this.bookModel});
  final BookModel bookModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      height: 500,
      child: Column(
        children: [
          Expanded(child: Image.asset(bookModel.cover, fit: BoxFit.cover)),
          SizedBox(height: 10),
          Text(
            bookModel.author,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(bookModel.title, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

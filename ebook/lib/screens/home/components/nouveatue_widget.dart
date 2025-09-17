import 'package:ebook/models/book_model.dart';
import 'package:ebook/screens/home/detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NouveauteWidget extends StatelessWidget {
  const NouveauteWidget({super.key, required this.bookModel});
  final BookModel bookModel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => Detailpage(bookModel: bookModel),
          ),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            Expanded(
              child: Hero(
                tag: bookModel.id, // Make sure `id` exists in BookModel
                child: Image.network(
  bookModel.cover, 
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
)

              ),
            ),
            const SizedBox(height: 5),
            Text(
              bookModel.author,
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              bookModel.title,
              style: Theme.of(context).textTheme.labelLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

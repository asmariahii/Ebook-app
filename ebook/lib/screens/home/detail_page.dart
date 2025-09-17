import 'package:ebook/models/book_model.dart';
import 'package:ebook/utils/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readmore/readmore.dart';
import '../../pages/pdf_view_page.dart';

class Detailpage extends StatefulWidget {
  const Detailpage({super.key, required this.bookModel});
  final BookModel bookModel;

  @override
  State<Detailpage> createState() => _DetailpageState();
}

class _DetailpageState extends State<Detailpage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: SvgPicture.asset(
            "assets/images/logo-spotify.svg",
            height: 30,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: widget.bookModel.id,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.bookModel.cover,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 80),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.bookModel.author,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 5),
                Text(
                  widget.bookModel.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(CupertinoIcons.heart),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(CupertinoIcons.download_circle),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(CupertinoIcons.ellipsis_vertical),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        CupertinoIcons.add_circled,
                        color: TColors.primary,
                      ),
                    ),
                    // PDF button
IconButton(
  onPressed: () {
    if (widget.bookModel.file.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewPage(
            url: widget.bookModel.file, // just use the file URL
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF not available")),
      );
    }
  },
  icon: Icon(CupertinoIcons.doc_text, color: TColors.primary),
),

                  ],
                ),
                const SizedBox(height: 10),
                ReadMoreText(
                  widget.bookModel.description,
                  trimMode: TrimMode.Line,
                  trimLines: 4,
                  style: Theme.of(context).textTheme.bodyMedium,
                  colorClickableText: TColors.primary,
                  trimCollapsedText: 'Show more',
                  trimExpandedText: 'Show less',
                  moreStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: TColors.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

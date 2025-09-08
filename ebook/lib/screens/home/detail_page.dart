import 'package:ebook/models/book_model.dart';
import 'package:ebook/utils/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readmore/readmore.dart';

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
          title: SvgPicture.asset("assets/images/logo-spotify.svg", height: 30),
        ),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: widget.bookModel.id,
                  child: Image.asset(
                    widget.bookModel.cover,
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  widget.bookModel.author,
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                Text(
                  widget.bookModel.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(CupertinoIcons.heart),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(CupertinoIcons.download_circle),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(CupertinoIcons.ellipsis_vertical),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        CupertinoIcons.add_circled,
                        color: TColors.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        CupertinoIcons.play_rectangle,
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ReadMoreText(
                  widget.bookModel.description,
                  trimMode: TrimMode.Line,
                  trimLines: 4,

                  style: Theme.of(context).textTheme.bodyMedium,
                  colorClickableText: TColors.primary,
                  trimCollapsedText: 'Show more',
                  trimExpandedText: 'Show less',
                  moreStyle: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: TColors.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

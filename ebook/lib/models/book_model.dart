class BookModel {
  String id;
  String title;
  String author;
  String description;
  String cover;
  String file;
  bool isTrending;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.cover,
    required this.file,
    required this.isTrending,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
        id: json["_id"], // from MongoDB
        title: json["title"],
        author: json["author"],
        description: json["description"],
        cover: json["cover"], // now full URL from Node.js
        file: json["file"],
        isTrending: json["isTrending"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "author": author,
        "description": description,
        "cover": cover,
        "file": file,
        "isTrending": isTrending,
      };
}

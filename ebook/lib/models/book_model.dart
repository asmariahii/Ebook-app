class BookModel {
  final int id;
  final String title;
  final String author;
  final String description;
  final String cover; // path to book cover image
  final String file;  // path or URL to the book file (e.g., PDF, EPUB)

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.cover,
    required this.file,
  });
}
// Main list of books
List<BookModel> bookList = [
  BookModel(
    id: 1,
    title: "The Great Gatsby",
    author: "F. Scott Fitzgerald",
    description:
        "A classic novel set in the Jazz Age, exploring themes of wealth, love, and the American Dream.",
    cover: "assets/images/book1.jpeg",
    file: "assets/books/great_gatsby.pdf",
  ),
  BookModel(
    id: 2,
    title: "1984",
    author: "George Orwell",
    description:
        "A dystopian novel that explores totalitarianism, surveillance, and individual freedom.",
    cover: "assets/images/book2.jpeg",
    file: "assets/books/1984.pdf",
  ),
  BookModel(
    id: 3,
    title: "Pride and Prejudice",
    author: "Jane Austen",
    description:
        "A timeless romance novel that critiques social class and marriage in 19th-century England.",
    cover: "assets/images/book3.jpeg",
    file: "assets/books/pride_prejudice.pdf",
  ),
];

List<BookModel> trendingBooks = [
  BookModel(
    id: 11,
    title: "Atomic Habits",
    author: "James Clear",
    description:
        "A self-help book about building good habits and breaking bad ones through small, consistent changes.",
    cover: "assets/images/book4.jpeg",
    file: "assets/books/atomic_habits.pdf",
  ),
  BookModel(
    id: 12,
    title: "The Subtle Art of Not Giving a F*ck",
    author: "Mark Manson",
    description:
        "A counterintuitive guide to living a better life by focusing on what truly matters.",
    cover: "assets/images/book5.jpeg",
    file: "assets/books/subtle_art.pdf",
  ),
];

List<BookModel> searchBooks = [
  BookModel(
    id: 21,
    title: "Harry Potter and the Sorcerer's Stone",
    author: "J.K. Rowling",
    description:
        "The first book in the Harry Potter series, introducing the world of magic, Hogwarts, and Harry's adventures.",
    cover: "assets/images/book6.jpeg",
    file: "assets/books/harry_potter1.pdf",
  ),
];

enum BookType {
  ebook,      // Elektron PDF
  physical,   // Kitabxanada fiziki nüsxə
  both,       // Həm elektron, həm fiziki
}

class BookItem {
  final String id;
  final String title;
  final String author;
  final String category; // "Dərslik", "Bədii", "Elmi", "Xarici Dil", "IB Resurs"
  final String coverUrl;
  final BookType type;
  final int pageCount;
  final String language; // "Azərbaycan", "İngilis", "Rus"
  final int availableCopies;
  final bool isBorrowedByMe;
  final DateTime? returnDeadline;
  final String description;
  final double rating;

  BookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.coverUrl,
    required this.type,
    required this.pageCount,
    required this.language,
    required this.availableCopies,
    this.isBorrowedByMe = false,
    this.returnDeadline,
    required this.description,
    this.rating = 4.8,
  });
}

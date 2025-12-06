class Author {
  final int? id;
  final String name;
  final String? bio;
  final String? photo;
  final int? bookCount;

  Author({
    this.id,
    required this.name,
    this.bio,
    this.photo,
    this.bookCount,
  });

  factory Author.fromMap(Map<String, dynamic> map) {
    return Author(
      id: map['id'],
      name: map['name'],
      bio: map['bio'],
      photo: map['photo'],
      bookCount: map['book_count'],
    );
  }
}

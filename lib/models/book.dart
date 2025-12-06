class Book {
  final int? id;
  final int? categoryId;
  final String title;
  final String? coverImage;
  final String? filePath;
  final String? description;
  final int? pages;
  final int? publishYear;
  final String? status;
  final double? rating;
  final String? notes;
  final bool? favorite;
  final String? addedAt;
  final String? finishedAt;
  final List<String>? authors;
  final List<int>? authorIds;

  Book({
    this.id,
    this.categoryId,
    required this.title,
    this.coverImage,
    this.filePath,
    this.description,
    this.pages,
    this.publishYear,
    this.status,
    this.rating,
    this.notes,
    this.favorite,
    this.addedAt,
    this.finishedAt,
    this.authors,
    this.authorIds,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      categoryId: map['category_id'],
      title: map['title'],
      coverImage: map['cover_image'],
      filePath: map['file_path'],
      description: map['description'],
      pages: map['pages'],
      publishYear: map['publish_year'],
      status: map['status'],
      rating: map['rating'],
      notes: map['notes'],
      favorite: map['favorite'] == 1,
      addedAt: map['added_at'],
      finishedAt: map['finished_at'],
      authors: map['authors'] != null ? (map['authors'] as String).split(',') : null,
      authorIds: map['author_ids'] != null ? (map['author_ids'] as String).split(',').map((e) => int.parse(e)).toList() : null,
    );
  }
}

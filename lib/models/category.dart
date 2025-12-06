class Category {
  final int? id;
  final int shelfId;
  final String name;
  final String? description;
  final String? icon;

  Category({
    this.id,
    required this.shelfId,
    required this.name,
    this.description,
    this.icon,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      shelfId: map['shelf_id'],
      name: map['name'],
      description: map['description'],
      icon: map['icon'],
    );
  }
}

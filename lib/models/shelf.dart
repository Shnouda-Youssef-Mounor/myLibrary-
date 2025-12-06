class Shelf {
  final int? id;
  final String name;
  final String? description;
  final String? color;

  Shelf({
    this.id,
    required this.name,
    this.description,
    this.color,
  });

  factory Shelf.fromMap(Map<String, dynamic> map) {
    return Shelf(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      color: map['color'],
    );
  }
}

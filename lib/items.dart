import 'dart:developer';

class Item {
  const Item({this.id, required this.name, this.quantity, this.imagePath});

  final dynamic id;
  final String name;
  final String? quantity;
  final String? imagePath;

  factory Item.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {"id": dynamic id, "name": String name} =>
          Item(id: id, name: name),
      _ => throw const FormatException('Failed to load item.'),
    };
  }
}
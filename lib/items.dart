class Item {
  const Item({this.id, required this.name, this.quantity, this.imagePath});

  final int? id;
  final String name;
  final String? quantity;
  final String? imagePath;
}
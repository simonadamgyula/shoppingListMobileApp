import 'package:flutter/cupertino.dart';

class Item {
  const Item({this.id, required this.name, this.quantity, this.imagePath, this.bought});

  final dynamic id;
  final String name;
  final String? quantity;
  final String? imagePath;
  final bool? bought;

  factory Item.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {"id": String id, "name": String name} =>
          Item(id: id, name: name),
      {"id": String id, "name": String name, "src": String src} =>
          Item(id: id, name: name, imagePath: src),
      _ => throw const FormatException('Failed to load item.'),
    };
  }
}

class ItemsStorage extends ChangeNotifier {
  ItemsStorage({required this.itemsToBuy, required this.itemsBought});

  List<Item> itemsToBuy;
  List<Item> itemsBought;

  void addItem(Item item) {
    itemsToBuy.add(item);

    notifyListeners();
  }

  void itemBought(Item item) {
    itemsToBuy.remove(item);
    itemsBought.add(item);

    notifyListeners();
  }

  void itemNotBought(Item item) {
    itemsBought.remove(item);
    itemsBought.add(item);

    notifyListeners();
  }

  void clearBought() {
    itemsBought.clear();

    notifyListeners();
  }

  List<Item> getItemsToBuy() {
    return itemsToBuy;
  }
}
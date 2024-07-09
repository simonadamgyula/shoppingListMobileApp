import 'dart:convert';

import 'package:app/http_request.dart';
import 'package:app/session.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Item {
  Item({this.id, required this.name, this.quantity, this.imagePath, this.bought});

  final String? id;
  final String name;
  final String? quantity;
  final String? imagePath;
  bool? bought;

  factory Item.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {"id": String id, "name": String name, "src": String src} =>
        Item(id: id, name: name, imagePath: src),
      {"id": String id, "name": String name} => Item(id: id, name: name),
      _ => throw const FormatException('Failed to load item.'),
    };
  }

  Map<String, dynamic> toJson() =>
      {"name": name, "quantity": quantity, "image": imagePath, "bought": bought};
}

class ItemsStorage extends ChangeNotifier {
  ItemsStorage._internal(
      {required this.itemsToBuy, required this.itemsBought, required this.householdId});

  List<Item> itemsToBuy;
  List<Item> itemsBought;
  final int householdId;

  factory ItemsStorage(List<Item> items, int householdId) {
    final bought = items.where((item) => item.bought ?? false).toList();
    final toBuy = items.where((item) => !(item.bought ?? false)).toList();

    return ItemsStorage._internal(
        itemsToBuy: toBuy, itemsBought: bought, householdId: householdId);
  }

  void addItem(Item item) {
    final session = Session();
    if (session.getSessionId() == null) return;

    sendApiRequest(
      "/household/items/add",
      {
        "session_id": session.getSessionId(),
        "household_id": householdId,
        "item": item.toJson()
      },
      headers: {
        "Content-Type": "application/json",
      },
    );

    itemsToBuy.add(item);

    notifyListeners();
  }

  void itemSetBought(Item item, bool bought) {
    final session = Session();
    if (session.getSessionId() == null) return;

    sendApiRequest(
      "/household/items/set_bought",
      {
        "session_id": session.getSessionId(),
        "household_id": householdId,
        "item": item.name,
        "bought": bought
      },
      headers: {"Content-Type": "application/json"},
    );

    if (bought) {
      itemsToBuy.remove(item);
      itemsBought.add(item);
      item.bought = bought;
    } else {
      itemsBought.remove(item);
      itemsToBuy.add(item);
      item.bought = bought;
    }

    notifyListeners();
  }

  void clearBought() {
    for (var item in itemsBought) {
      removeItem(item);
    }

    itemsBought.clear();

    notifyListeners();
  }

  void removeItem(Item item) {
    final session = Session();
    if (session.getSessionId() == null) return;

    sendApiRequest(
      "/household/items/remove",
      {
        "session_id": session.getSessionId(),
        "household_id": householdId,
        "item": item.name
      },
      headers: {"Content-Type": "application/json"},
    );
  }

  List<Item> getItemsToBuy() {
    return itemsToBuy;
  }

  List<Item> getBoughtItems() {
    return itemsBought;
  }
}

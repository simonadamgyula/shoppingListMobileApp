import 'package:app/catalog.dart';
import 'package:app/session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:session_storage/session_storage_generic.dart';

import 'households.dart';
import 'items.dart';

class HouseholdPage extends StatefulWidget {
  final int id;

  const HouseholdPage({super.key, required this.id});

  @override
  State<HouseholdPage> createState() => _HouseholdPageState();
}

class _HouseholdPageState extends State<HouseholdPage> {
  Future<Household?>? _futureHousehold;

  @override
  Widget build(BuildContext context) {
    final session = Session();
    _futureHousehold = getHousehold(session.getSessionId(), widget.id);

    return FutureBuilder<Household?>(
        future: _futureHousehold,
        builder: (BuildContext context, AsyncSnapshot<Household?> snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Loading"),
              ),
              body: const CircularProgressIndicator(),
            );
          }

          final household = snapshot.data;

          if (household == null) {
            Navigator.pop(context);
            return const Text("");
          }

          return Scaffold(
              backgroundColor: const Color(0xFF2F3C42),
              appBar: AppBar(
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(
                  household.name,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                ),
                backgroundColor: const Color(0xFF2F3C42),
              ),
              body: ChangeNotifierProvider<ItemsStorage>(
                create: (BuildContext context) => ItemsStorage(household.items ?? [], widget.id),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          child: Text(
                            "To buy",
                            style: TextStyle(
                                color: Color(0x66ffffff),
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Consumer(
                        builder: (context, ItemsStorage itemsStorage, child) {
                          return Wrap(
                            children: itemsStorage
                                .getItemsToBuy()
                                .map((item) => ItemCard(
                                      item: item,
                                      itemsStorage: itemsStorage,
                                    ))
                                .toList(),
                          );
                        },
                      ),
                      Consumer(
                        builder: (context, ItemsStorage itemsStorage, child) {
                          return Wrap(
                            children: itemsStorage
                                .getBoughtItems()
                                .map((item) => ItemCard(
                                      item: item,
                                      itemsStorage: itemsStorage,
                                    ))
                                .toList(),
                          );
                        },
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Consumer<ItemsStorage>(
                            builder: (context, ItemsStorage itemsStorage, child) {
                          return Catalog(
                            itemsStorage: itemsStorage,
                          );
                        }),
                      )
                    ],
                  ),
                ),
              ));
        });
  }
}

class ItemCard extends StatefulWidget {
  const ItemCard({super.key, required this.item, required this.itemsStorage});

  final Item item;
  final ItemsStorage itemsStorage;

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  final TextEditingController quantityController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    quantityController.dispose();
    super.dispose();
  }

  Future<void> _addDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text("Add ${widget.item.name} to list"),
            children: [
              TextField(
                decoration: const InputDecoration(
                    labelText: "Quantity", labelStyle: TextStyle(color: Colors.white)),
                controller: quantityController,
                style: const TextStyle(color: Colors.white),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        final itemToAdd = Item(
                            id: widget.item.id,
                            name: widget.item.name,
                            bought: false,
                            quantity: quantityController.text);
                        widget.itemsStorage.addItem(itemToAdd);

                        Navigator.of(context).pop();
                      },
                      child: const Text("Add")),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel")),
                ],
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.item.bought != null) {
          widget.itemsStorage.itemSetBought(widget.item, !(widget.item.bought ?? false));
          return;
        }

        _addDialog(context);
      },
      child: Card(
        color: Color((widget.item.bought ?? false) ? 0xffddb135 : 0xff00A894),
        child: SizedBox(
          width: 90,
          height: 110,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.item.name,
                textAlign: TextAlign.center,
              ),
              Text(widget.item.quantity ?? "")
            ],
          ),
        ),
      ),
    );
  }
}

class Catalog extends StatefulWidget {
  const Catalog({super.key, required this.itemsStorage});

  final ItemsStorage itemsStorage;

  @override
  State<Catalog> createState() => _CatalogState();
}

class _CatalogState extends State<Catalog> {
  final List<Map<String, dynamic>> _catalog = getCatalog();

  @override
  Widget build(BuildContext context) {
    return Column(
        children: _catalog
            .map((section) => Section(
                  section: section,
                  itemsStorage: widget.itemsStorage,
                ))
            .toList());
  }
}

class Section extends StatelessWidget {
  const Section({super.key, required this.section, required this.itemsStorage});

  final Map<String, dynamic> section;
  final ItemsStorage itemsStorage;

  @override
  Widget build(BuildContext context) {
    final List<Item> items =
        (section["items"] as List<dynamic>).map((item) => Item.fromJson(item)).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          Text(section["name"]),
          Wrap(
            children: items.map((item) => ItemCard(item: item, itemsStorage: itemsStorage,)).toList(),
          )
        ],
      ),
    );
  }
}

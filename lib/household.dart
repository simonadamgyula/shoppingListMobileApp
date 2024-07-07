import 'package:app/catalog.dart';
import 'package:app/session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
              backgroundColor: const Color(0xFF2F3C42),
              appBar: AppBar(
                title: const Text(
                  "Loading",
                  style: TextStyle(
                      color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                ),
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
              body: HouseholdBody(household: household, widget: widget));
        });
  }
}

class HouseholdBody extends StatelessWidget {
  const HouseholdBody({
    super.key,
    required this.household,
    required this.widget,
  });

  final Household household;
  final HouseholdPage widget;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ItemsStorage>(
      create: (BuildContext context) => ItemsStorage(household.items ?? [], widget.id),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "To buy",
                  style: TextStyle(
                      color: Color(0x66ffffff),
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
              Consumer(
                builder: (context, ItemsStorage itemsStorage, child) {
                  if (itemsStorage.getItemsToBuy().isEmpty) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: const Align(
                        child: Text(
                          "Nothing to buy",
                          style: TextStyle(
                              color: Color(0xaaffffff),
                              fontSize: 20,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    );
                  }

                  return Wrap(
                    alignment: WrapAlignment.start,
                    runSpacing: 8,
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
              Consumer<ItemsStorage>(
                  builder: (context, ItemsStorage itemsStorage, child) {
                if (itemsStorage.getBoughtItems().isEmpty) {
                  return const SizedBox();
                }

                return Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Bought",
                        style: TextStyle(
                            color: Color(0x66ffffff),
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                      IconButton(
                          onPressed: () {
                            itemsStorage.clearBought();
                          },
                          icon: const Icon(
                            Icons.check_circle_outline,
                            color: Color(0x88ffffff),
                          ))
                    ],
                  ),
                );
              }),
              Consumer(
                builder: (context, ItemsStorage itemsStorage, child) {
                  return Wrap(
                    alignment: WrapAlignment.start,
                    runSpacing: 8,
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
              Consumer<ItemsStorage>(
                  builder: (context, ItemsStorage itemsStorage, child) {
                return Catalog(
                  itemsStorage: itemsStorage,
                );
              })
            ],
          ),
        ),
      ),
    );
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
                    labelText: "Quantity", labelStyle: TextStyle(color: Colors.black)),
                controller: quantityController,
                style: const TextStyle(color: Colors.black),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        final itemToAdd = Item(
                            name: widget.item.name,
                            bought: false,
                            quantity: quantityController.text,
                            imagePath: widget.item.imagePath ??
                                "https://web.getbring.com/assets/images/items/${widget.item.id!.toLowerCase().replaceAll(RegExp(r"/( |-)/g"), "_")}.png");
                        widget.itemsStorage.addItem(itemToAdd);
                        quantityController.clear();

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

  String getImageUrl() {
    final item = widget.item;
    if (item.imagePath != null) {
      return item.imagePath!;
    }

    return "https://web.getbring.com/assets/images/items/${item.id!.toLowerCase().replaceAll(RegExp(r"( |-)"), "_")}.png";
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
          width: 80,
          height: 110,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(getImageUrl(), height: 50, width: 35, fit: BoxFit.contain),
              Text(
                widget.item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              widget.item.quantity != null
                  ? Text(widget.item.quantity!,
                      style: const TextStyle(color: Colors.white))
                  : const SizedBox()
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
  List<Map<String, dynamic>> _catalog = getCatalog();
  bool search = false;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      final query = searchController.text;
      setState(() {
        search = query != "";
        _catalog = searchCatalog(query);
      });
    });
  }

  Item generateOther() {
    final query = searchController.text;

    return Item(
        id: query.toLowerCase().replaceAll(RegExp(r"/( |-)/g"), "_"),
        name: query,
        imagePath:
            "https://web.getbring.com/assets/images/items/${query.toLowerCase()[0]}.png");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Color(0x33000000),
      ),
      padding: EdgeInsets.only(left: 10, right: 10, bottom: search ? 10 : 0),
      margin: const EdgeInsets.only(top: 20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
                TextField(
                  decoration: const InputDecoration(
                      hintText: "Search", hintStyle: TextStyle(color: Colors.white)),
                  controller: searchController,
                  style: const TextStyle(color: Colors.white),
                ),
              ] +
              _catalog
                  .map((section) => Section(
                        section: section,
                        itemsStorage: widget.itemsStorage,
                      ))
                  .toList() +
              [
                search
                    ? ItemCard(item: generateOther(), itemsStorage: widget.itemsStorage)
                    : const SizedBox()
              ]),
    );
  }
}

class Section extends StatefulWidget {
  const Section({super.key, required this.section, required this.itemsStorage});

  final Map<String, dynamic> section;
  final ItemsStorage itemsStorage;

  @override
  State<Section> createState() => _SectionState();
}

class _SectionState extends State<Section> {
  bool opened = false;

  @override
  Widget build(BuildContext context) {
    final List<Item> items = (widget.section["items"] as List<dynamic>)
        .map((item) => Item.fromJson(item))
        .toList();

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
                onTap: () {
                  setState(() {
                    opened = !opened;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.section["name"],
                      style: const TextStyle(
                          color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Icon(
                      opened ? Icons.arrow_right : Icons.arrow_drop_down,
                      color: Colors.white,
                      size: 30,
                    )
                  ],
                )),
            opened
                ? Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    runSpacing: 6,
                    children: items
                        .map((item) => ItemCard(
                              item: item,
                              itemsStorage: widget.itemsStorage,
                            ))
                        .toList(),
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}

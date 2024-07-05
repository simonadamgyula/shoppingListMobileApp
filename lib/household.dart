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
                create: (BuildContext context) =>
                    ItemsStorage(itemsToBuy: household.items ?? [], itemsBought: []),
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
                        builder: (context, ItemsStorage itemStorage, child) {
                          return Row(
                            children: itemStorage
                                .getItemsToBuy()
                                .map((item) => ItemCard(item: item))
                                .toList(),
                          );
                        },
                      ),
                      const Align(
                        alignment: Alignment.center,
                        child: Catalog(),
                      )
                    ],
                  ),
                ),
              ));
        });
  }
}

class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff00A894),
      child: SizedBox(
        width: 90,
        height: 110,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              item.name,
              textAlign: TextAlign.center,
            ),
            Text(item.quantity ?? "")
          ],
        ),
      ),
    );
  }
}

class Catalog extends StatefulWidget {
  const Catalog({super.key});

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
                ))
            .toList());
  }
}

class Section extends StatelessWidget {
  const Section({super.key, required this.section});

  final Map<String, dynamic> section;

  @override
  Widget build(BuildContext context) {
    final List<Item> items =
        (section["items"] as List<dynamic>).map((item) => Item.fromJson(item)).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          Text(section["name"]),
          Wrap(
            children: items.map((item) => ItemCard(item: item)).toList(),
          )
        ],
      ),
    );
  }
}

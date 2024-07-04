import 'package:app/session.dart';
import 'package:flutter/material.dart';

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
            return const CircularProgressIndicator();
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
              body: const Column(
                children: <Widget>[
                  Align(
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
                  Row(
                    children: [
                      ItemCard(item: Item(name: "milk", quantity: "2l")),
                      ItemCard(item: Item(name: "orange"))
                    ],
                  )
                ],
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
        width: 60,
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Text(item.name), Text(item.quantity ?? "")],
        ),
      ),
    );
  }
}

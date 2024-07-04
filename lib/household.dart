import 'package:app/session.dart';
import 'package:flutter/material.dart';

import 'households.dart';

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

          return Scaffold(
              backgroundColor: const Color(0xFF2F3C42),
              appBar: AppBar(
                iconTheme: const IconThemeData(color: Colors.white),
                title: const Text(
                  "Login",
                  style: TextStyle(
                      color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                ),
                backgroundColor: const Color(0xFF2F3C42),
              ),
              body: const Text("text"));
        });
  }
}

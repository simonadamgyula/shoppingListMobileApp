import 'dart:developer';

import 'package:app/households.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:session_storage/session_storage.dart';

import 'login.dart';

final loginNotifier = ValueNotifier("");

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopMate',
      theme: ThemeData(),
      home: const HomePage(title: 'ShopMate'),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final session = SessionStorage();

    log((session["session_id"] == null) ? "true" : "false");

    return Scaffold(
        backgroundColor: const Color(0xFF2F3C42),
        appBar: AppBar(
          title: Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF2F3C42),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Households",
                            style: TextStyle(
                                color: Color(0xCCFFFFFF),
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                              onPressed: null,
                              icon: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 30,
                              ))
                        ]))),
            Center(
                child: ValueListenableBuilder<String>(
                    valueListenable: loginNotifier,
                    builder: (context, value, child) {
                      return Households(loginNotifier: loginNotifier,);
                    })),
            Text("${session["session_id"]}"),
            const LoginButton()
          ],
        ));
  }
}

class LoginButton extends StatefulWidget {
  const LoginButton({super.key});

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const LoginPage()))
            },
        icon: const Icon(Icons.login));
  }
}

class Households extends StatefulWidget {
  final ValueListenable<String> loginNotifier;

  const Households({super.key, required this.loginNotifier});

  @override
  State<Households> createState() => HouseholdsState();
}

class HouseholdsState extends State<Households> {
  Future<List<Household>>? _futureHouseholds;

  @override
  void initState() {
    super.initState();
    final session = SessionStorage();

    _futureHouseholds = getHouseholds(session["session_id"]);
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionStorage();
    _futureHouseholds = getHouseholds(session["session_id"]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: (_futureHouseholds == null)
          ? <Widget>[
              const HouseholdCard(title: "Household"),
              const HouseholdCard(title: "Household 2")
            ]
          : [const Text("nothing")],
    );
  }
}

class HouseholdCard extends StatelessWidget {
  const HouseholdCard({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
        child: Card(
          color: const Color(0xFFEF4F4F),
          child: SizedBox(
            height: 180,
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                )),
          ),
        ));
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';

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
      home: const MyHomePage(title: 'ShopMate'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
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
        body: const Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Align(
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
            Center(child: Households())
          ],
        ));
  }
}

class Households extends StatelessWidget {
  const Households({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        HouseholdCard(title: "Household"),
        HouseholdCard(title: "Household 2")
      ],
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
                  style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                )),
          ),
        ));
  }
}

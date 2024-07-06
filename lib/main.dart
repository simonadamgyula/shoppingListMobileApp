import 'dart:developer';

import 'package:app/add_household.dart';
import 'package:app/household.dart';
import 'package:app/households.dart';
import 'package:app/profile_page.dart';
import 'package:app/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'ShopMate',
      theme: ThemeData(),
      home: const HomePage(title: 'ShopMate'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool finishedInit = false;

  Future<void> loadSessionId() async {
    final session = Session();
    final prefs = await SharedPreferences.getInstance();

    final sessionId = prefs.getString("session_id");

    log(sessionId ?? "null");

    if (sessionId != null) session.setSessionId(sessionId);
    setState(() {
      finishedInit = true;
    });
  }

  @override
  void initState() {
    super.initState();

    loadSessionId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF2F3C42),
        appBar: AppBar(
          title: Text(
            widget.title,
            style: const TextStyle(
                color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const ProfilePage()));
                    },
                    child: const Image(
                      image: AssetImage("assets/img/placeholder_pfp.png"),
                      height: 30,
                      width: 30,
                    ),
                  )),
            )
          ],
          backgroundColor: const Color(0xFF2F3C42),
        ),
        body: ChangeNotifierProvider<Session>(
            create: (context) => Session(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Text(
                                "Households",
                                style: TextStyle(
                                    color: Color(0xCCFFFFFF),
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold),
                              ),
                              Consumer<Session>(builder: (context, session, child) {
                                return IconButton(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const AddHouseholdPage()));

                                      if (!context.mounted) return;
                                      if (!result) return;

                                      session.updateHouseholds();
                                    },
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 30,
                                    ));
                              })
                            ]))),
                Consumer<Session>(builder: (context, session, child) {
                  return session.getSessionId() == null
                      ? LoginButton(session: session)
                      : Center(child: Households(session: session));
                })
              ],
            )));
  }
}

class LoginButton extends StatefulWidget {
  final Session session;

  const LoginButton({super.key, required this.session});

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: () => {logIn(context)}, icon: const Icon(Icons.login));
  }

  Future<void> saveSessionId(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("session_id", sessionId);
  }

  Future<void> logIn(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );

    if (!context.mounted) return;

    widget.session.setSessionId(result);
    saveSessionId(result);
  }
}

class Households extends StatefulWidget {
  final Session session;

  const Households({super.key, required this.session});

  @override
  State<Households> createState() => HouseholdsState();
}

class HouseholdsState extends State<Households> {
  Future<List<Household>>? _futureHouseholds;

  @override
  void initState() {
    super.initState();

    _futureHouseholds = getHouseholds(widget.session.getSessionId());
  }

  @override
  Widget build(BuildContext context) {
    final sessionId = widget.session.getSessionId();
    _futureHouseholds = getHouseholds(sessionId);

    return FutureBuilder(
        future: _futureHouseholds,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: snapshot.data!
                    .map((household) => HouseholdCard(
                          title: household.name,
                          color: household.color,
                          id: household.id,
                        ))
                    .toList());
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          return const CircularProgressIndicator();
        });
  }
}

class HouseholdCard extends StatelessWidget {
  const HouseholdCard(
      {super.key, required this.title, required this.color, required this.id});

  final String title;
  final int color;
  final int id;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
        child: InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HouseholdPage(id: id)));
          },
          child: Card(
            color: HSLColor.fromAHSL(1, color.toDouble(), 0.83, 0.62).toColor(),
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
          ),
        ));
  }
}

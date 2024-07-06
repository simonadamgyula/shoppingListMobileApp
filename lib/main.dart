import 'dart:convert';
import 'dart:developer';

import 'package:app/add_household.dart';
import 'package:app/household.dart';
import 'package:app/households.dart';
import 'package:app/profile_page.dart';
import 'package:app/register.dart';
import 'package:app/session.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';
import 'package:http/http.dart' as http;

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

  Future<void> logOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("session_id");
  }

  @override
  void initState() {
    super.initState();

    loadSessionId();
  }

  Future<void> saveSessionId(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("session_id", sessionId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Session>(
        create: (context) => Session(),
        child: Scaffold(
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
                      child: Consumer<Session>(
                        builder: (context, session, child) {
                          if (session.getSessionId() == null) {
                            return Consumer<Session>(
                              builder: (context, session, child) {
                                return RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text: "Log in",
                                        style:
                                            const TextStyle(fontWeight: FontWeight.bold),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const LoginPage()));

                                            if (!context.mounted) return;

                                            if (result != null) {
                                              session.setSessionId(result);
                                              saveSessionId(result);
                                            }
                                          }),
                                    const TextSpan(text: " / "),
                                    TextSpan(
                                        text: "Register",
                                        style:
                                            const TextStyle(fontWeight: FontWeight.bold),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const RegisterPage()));

                                            if (!context.mounted) return;

                                            if (result != null) {
                                              session.setSessionId(result);
                                              saveSessionId(result);
                                            }
                                          }),
                                  ]),
                                );
                              },
                            );
                          }

                          return InkWell(
                            onTap: () async {
                              final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const ProfilePage()));

                              if (!context.mounted) return;

                              if (result != null && result) {
                                session.logOut();
                                logOut();
                              }
                            },
                            child: const Image(
                              image: AssetImage("assets/img/placeholder_pfp.png"),
                              height: 30,
                              width: 30,
                            ),
                          );
                        },
                      )),
                )
              ],
              backgroundColor: const Color(0xFF2F3C42),
            ),
            body: Column(
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
                      ? const Text(
                          "You are not logged in.",
                          style: TextStyle(color: Color(0xaaffffff)),
                        )
                      : Center(child: Households(session: session));
                })
              ],
            )));
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
                          session: widget.session,
                        ))
                    .toList());
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          return const CircularProgressIndicator();
        });
  }
}

class HouseholdCard extends StatefulWidget {
  const HouseholdCard(
      {super.key,
      required this.title,
      required this.color,
      required this.id,
      required this.session});

  final String title;
  final int color;
  final int id;
  final Session session;

  @override
  State<HouseholdCard> createState() => _HouseholdCardState();
}

class _HouseholdCardState extends State<HouseholdCard> {
  Future<void> leaveHousehold() async {
    final result = await http.post(Uri.parse("http://192.168.1.93:8001/household/leave"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"session_id": widget.session.getSessionId(), "household_id": widget.id}));

    if (result.statusCode != 200) {
      throw Error();
    }

    widget.session.updateHouseholds();
  }

  void openActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: Center(
            child: Column(
              children: [
                const TextButton(
                  onPressed: null,
                  child: Text(
                    "Edit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const TextButton(
                  onPressed: null,
                  child: Text(
                    "Code",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    leaveHousehold().then((response) {
                      Navigator.pop(context);
                    });
                  },
                  child: const Text(
                    "Leave",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: const Color(0xff20292D),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: Stack(
        alignment: Alignment.bottomRight,
        fit: StackFit.passthrough,
        children: [
          Card(
            color: HSLColor.fromAHSL(1, widget.color.toDouble(), 0.83, 0.62).toColor(),
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HouseholdPage(id: widget.id)));
              },
              child: SizedBox(
                height: 180,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 10,
            child: IconButton(
              onPressed: () {
                openActions(context);
              },
              icon: const Icon(
                Icons.more_vert_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}

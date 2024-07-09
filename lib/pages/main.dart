import 'dart:convert';
import 'dart:developer';

import 'package:ShopMate/pages/profile_page.dart';
import 'package:ShopMate/pages/register.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_household.dart';
import '../households.dart';
import '../http_request.dart';
import '../session.dart';
import 'household.dart';
import 'household_edit.dart';
import 'login.dart';

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
                                      if (result == null) return;

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
                          household: household,
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
  const HouseholdCard({super.key, required this.household, required this.session});

  final Household household;
  final Session session;

  @override
  State<HouseholdCard> createState() => _HouseholdCardState();
}

class _HouseholdCardState extends State<HouseholdCard> {
  Future<String?>? _futureJoinCode;

  Future<bool> leaveHousehold() async {
    final result = await sendApiRequest(
      "/household/leave",
      {"session_id": widget.session.getSessionId(), "household_id": widget.household.id},
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (result.statusCode != 200) {
      log("error");
      throw Error();
    }

    return true;
  }

  Future<String?> createJoinCode() async {
    final result = await sendApiRequest(
      "/household/new_code",
      {"session_id": widget.session.getSessionId(), "household_id": widget.household.id},
    );

    if (result.statusCode != 200) return null;

    final body = jsonDecode(result.body);

    if (context.mounted) {
      Navigator.pop(context);
      openActions(context);
    }

    return body["code"] as String;
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
                TextButton(
                  onPressed: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HouseholdEditPage(id: widget.household.id)));

                    if (!context.mounted) return;

                    widget.session.updateHouseholds();
                  },
                  child: const Text(
                    "Edit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FutureBuilder<String?>(
                  builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                    if (!snapshot.hasData) {
                      return TextButton(
                        onPressed: () {
                          setState(() {
                            _futureJoinCode = createJoinCode();
                          });
                        },
                        child: const Text(
                          "Code",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    final code = snapshot.data!;

                    return TextButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: code)).then((result) {
                          Fluttertoast.showToast(
                              msg: "Code copied to clipboard",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: const Color(0x88000000),
                              textColor: Colors.white,
                              fontSize: 16);
                        });
                      },
                      child: Text(
                        code,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                  future: _futureJoinCode,
                ),
                TextButton(
                  onPressed: () {
                    leaveHousehold().then((response) {
                      Navigator.pop(context);
                      setState(() {
                        widget.session.updateHouseholds();
                      });
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
          Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 30.0,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Card(
              color: HSLColor.fromAHSL(1, widget.household.color.toDouble(), 0.83, 0.62)
                  .toColor(),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HouseholdPage(id: widget.household.id)));
                },
                child: SizedBox(
                  height: 180,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    child: Text(
                      widget.household.name,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                    ),
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

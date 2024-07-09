import 'dart:convert';

import 'package:flutter/material.dart';

import '../http_request.dart';
import '../profile.dart';
import '../session.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<Profile> getProfile(String sessionId) async {
    final response = await sendApiRequest(
      "/user/get_user",
      {"session_id": sessionId},
    );

    if (response.statusCode != 200) {
      throw Error();
    }

    return Profile.fromJson(jsonDecode(response.body));
  }

  @override
  Widget build(BuildContext context) {
    final session = Session();
    if (session.getSessionId() == null) {
      Navigator.pop(context);
      return const SizedBox();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF2F3C42),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F3C42),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
          future: getProfile(session.getSessionId()!),
          builder: (BuildContext context, AsyncSnapshot<Profile> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            final profile = snapshot.data!;
            _usernameController.text = profile.username;

            return Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Image(
                    image: AssetImage("assets/img/placeholder_pfp.png"),
                    width: 100,
                  ),
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    onEditingComplete: () {
                      profile.editProfile(_usernameController.text);
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.all(30),
                    margin: const EdgeInsets.only(top: 30),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xffcc0000), width: 4),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text(
                            "Danger zone",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Text(
                                "Log out of your account.",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text(
                                  "Log out",
                                  style: TextStyle(
                                    color: Color(0xffaa0000),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Text(
                                "Delete your account. This is not reversible.",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  profile.deleteAccount();
                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(
                                    color: Color(0xffaa0000),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ))
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }
}

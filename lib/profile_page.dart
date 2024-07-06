import 'dart:convert';

import 'package:app/profile.dart';
import 'package:app/session.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

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
    final response = await http.post(Uri.parse("http://192.168.1.93:8001/user/get_user"),
        body: jsonEncode({"session_id": sessionId}));

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
              return const CircularProgressIndicator();
            }

            final profile = snapshot.data!;
            _usernameController.text = profile.username;

            return Column(
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
                  child: Column(
                    children: [
                      const Text(
                        "Danger zone",
                        style: TextStyle(color: Colors.red),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Log out of your account"),
                          TextButton(onPressed: () {
                            Navigator.of(context).pop(true);
                          }, child: const Text("Log out", style: TextStyle(color: Color(0xffaa0000)),))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Delete your account. \nThis is not reversible."),
                          TextButton(onPressed: () {
                            profile.deleteAccount();
                          }, child: const Text("Delete", style: TextStyle(color: Color(0xffaa0000)),))
                        ],
                      )
                    ],
                  ),
                )
              ],
            );
          }),
    );
  }
}

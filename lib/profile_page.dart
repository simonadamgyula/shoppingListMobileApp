import 'dart:convert';

import 'package:app/profile.dart';
import 'package:app/session.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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


          return Column(
            children: [
              Text(profile.username, style: const TextStyle(color: Colors.white),)
            ],
          );
        }
      ),
    );
  }

}
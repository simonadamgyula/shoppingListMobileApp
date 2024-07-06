import 'dart:convert';

import 'package:app/session.dart';
import 'package:http/http.dart' as http;

class Profile {
  final String id;
  final String username;
  final String profilePicture;

  const Profile({required this.id, required this.username, required this.profilePicture});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {"id": String id, "username": String username, "profile_picture": String profilePicture} =>
          Profile(id: id, username: username, profilePicture: profilePicture),
      _ => throw const FormatException('Failed to load item.'),
    };
  }


  Future<void> deleteAccount() async {
    final session = Session();

    final result = await http.post(Uri.parse("http://192.168.1.93:8001/user/delete"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "session_id": session.getSessionId()
        }));

    if (result.statusCode != 200) {
      throw Error();
    }
  }

  Future<void> editProfile(String username) async {
    final session = Session();

    final result = await http.post(Uri.parse("http://192.168.1.93:8001/user/edit"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "session_id": session.getSessionId(),
          "username": username,
          "profile_picture": profilePicture
        }));

    if (result.statusCode != 200) {
      throw Error();
    }
  }
}
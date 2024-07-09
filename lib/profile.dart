import 'dart:convert';
import 'dart:developer';

import 'package:app/session.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Profile {
  final String id;
  final String username;
  final String profilePicture;
  String? permission;

  Profile(
      {required this.id,
      required this.username,
      required this.profilePicture,
      this.permission});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "id": String id,
        "username": String username,
        "profile_picture": String profilePicture,
        "permission": String permission
      } =>
        Profile(
            id: id,
            username: username,
            profilePicture: profilePicture,
            permission: permission),
      {
        "id": String id,
        "username": String username,
        "profile_picture": String profilePicture
      } =>
        Profile(id: id, username: username, profilePicture: profilePicture),
      _ => throw const FormatException('Failed to load item.'),
    };
  }

  @override
  String toString() {
    return "Profile($id, $username, $profilePicture, $permission)";
  }

  Future<void> deleteAccount() async {
    final session = Session();

    final result = await http.post(Uri.parse("http://192.168.1.93:8001/user/delete"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"session_id": session.getSessionId()}));

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

class MembersStorage extends ChangeNotifier {
  MembersStorage({required this.householdId, required this.users});

  List<Profile> users;
  final int householdId;

  void kickUser(Profile user) {
    log((householdId).toString());

    http.post(Uri.parse("http://192.168.1.93:8001/household/kick_member"),
        body: jsonEncode({
          "session_id": Session().getSessionId(),
          "household_id": householdId,
          "user_id": user.id,
        }));

    notifyListeners();
  }

  void editPermission(Profile user, String permission) {
    user.permission = permission;

    http.post(Uri.parse("http://192.168.1.93:8001/household/set_permission"),
        body: jsonEncode({
          "session_id": Session().getSessionId(),
          "household_id": householdId,
          "user_id": user.id,
          "permission": permission
        }));

    notifyListeners();
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:app/session.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'http_request.dart';

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

    final result = await sendApiRequest(
      "/user/delete",
      {"session_id": session.getSessionId()},
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (result.statusCode != 200) {
      throw Error();
    }
  }

  Future<void> editProfile(String username) async {
    final session = Session();

    final result = await sendApiRequest(
      "/user/edit",
      {
        "session_id": session.getSessionId(),
        "username": username,
        "profile_picture": profilePicture
      },
    );

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

    sendApiRequest(
      "/household/kick_member",
      {
        "session_id": Session().getSessionId(),
        "household_id": householdId,
        "user_id": user.id,
      },
    );

    notifyListeners();
  }

  void editPermission(Profile user, String permission) {
    user.permission = permission;

    sendApiRequest(
      "/household/set_permission",
      {
        "session_id": Session().getSessionId(),
        "household_id": householdId,
        "user_id": user.id,
        "permission": permission
      },
    );

    notifyListeners();
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;

class Household {
  final int id;
  final String name;
  final int color;

  const Household({required this.id, required this.name, required this.color});

  factory Household.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {"id": int id, "name": String name, "color": int color} =>
        Household(id: id, name: name, color: color),
      _ => throw const FormatException('Failed to load album.'),
    };
  }
}

Future<List<Household>> getHouseholds(String? sessionId) async {
  if (sessionId == null) return <Household>[];

  final response = await http.post(
      Uri.parse("http://192.168.1.93:8001/household"),
      body: jsonEncode({"session_id": sessionId})
  );

  if (response.statusCode != 200) {
    return <Household>[];
  }

  final householdList = jsonDecode(response.body)["households"] as List;
  final households = householdList.map((household) {
    return Household.fromJson(household);
  }).toList();

  return households;
}

Future<Household?> getHousehold(String? sessionId, int householdId) async {
  if (sessionId == null) throw StateError("Not logged in");

  final response = await http.post(
      Uri.parse("http://192.168.1.93:8001/household/get"),
      body: jsonEncode({
        "session_id": sessionId,
        "household_id": householdId
      })
  );

  if (response.statusCode == 401) {
    throw StateError("Not a member of this household");
  } else if (response.statusCode != 200) {
    return null;
  }

  final body = jsonDecode(response.body);

  return Household(id: householdId, name: body["name"], color: body["color"]);
}

Future<bool> joinHousehold(String? sessionId, String code) async {
  if (sessionId == null) throw StateError("Not logged in");

  final response = await http.post(
      Uri.parse("http://192.168.1.93:8001/household/join"),
      body: jsonEncode({
        "session_id": sessionId,
        "household_code": code
      })
  );

  if (response.statusCode != 200) {
    return false;
  }

  return true;
}

Future<bool> createHousehold(String? sessionId, String name, int color) async {
   if (sessionId == null) throw StateError("Not logged in");
   
   final response = await http.post(
     Uri.parse("http://192.168.1.93:8001/household/new"),
     body: jsonEncode({
       "session_id": sessionId,
       "name": name,
       "color": color
     })
   );

   if (response.statusCode != 200) {
     return false;
   }

   return true;
}
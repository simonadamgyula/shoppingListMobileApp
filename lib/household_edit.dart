import 'dart:convert';

import 'package:app/households.dart';
import 'package:app/profile.dart';
import 'package:app/session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HouseholdEditPage extends StatefulWidget {
  const HouseholdEditPage({super.key, required this.id});

  final int id;

  @override
  State<HouseholdEditPage> createState() => _HouseholdEditPageState();
}

class _HouseholdEditPageState extends State<HouseholdEditPage> {
  Future<Household?> getHouseholdIfAdmin(String? sessionId, int householdId) async {
    var response = await http.post(
        Uri.parse("http://192.168.1.93:8001/household/check_admin"),
        body: jsonEncode({"session_id": sessionId, "household_id": householdId}));

    if (response.statusCode != 200) throw Error();
    if (!jsonDecode(response.body)["is_admin"]) throw Error();

    return await getHousehold(sessionId, householdId).catchError((error) {
      throw Error();
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Session();
    final futureHousehold = getHouseholdIfAdmin(session.getSessionId(), widget.id);

    return FutureBuilder<Household?>(
      builder: (BuildContext context, AsyncSnapshot<Household?> snapshot) {
        if (snapshot.hasError) {
          Navigator.pop(context);
          return const SizedBox();
        }

        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: const Color(0xFF2F3C42),
            appBar: AppBar(
              title: const Text("Loading"),
              backgroundColor: const Color(0xFF2F3C42),
              foregroundColor: Colors.white,
            ),
            body: const CircularProgressIndicator(),
          );
        }

        final household = snapshot.data;
        if (household == null) {
          Navigator.pop(context);
          return const SizedBox();
        }

        return Scaffold(
            backgroundColor: const Color(0xFF2F3C42),
            appBar: AppBar(
              title: const Text(""),
              backgroundColor: const Color(0xFF2F3C42),
              foregroundColor: Colors.white,
            ),
            body: EditBody(
              household: household,
            ));
      },
      future: futureHousehold,
    );
  }
}

class EditBody extends StatefulWidget {
  const EditBody({
    super.key,
    required this.household,
  });

  final Household household;

  @override
  State<EditBody> createState() => _EditBodyState();
}

class _EditBodyState extends State<EditBody> {
  double _colorValue = 0;
  final TextEditingController _nameController = TextEditingController();

  Future<void> editHousehold() async {
    http.post(
      Uri.parse("http://192.168.1.93:8001/household/update"),
      body: jsonEncode({
        "session_id": Session().getSessionId(),
        "household_id": widget.household.id,
        "new_name": _nameController.text,
        "new_color": _colorValue
      }),
    );
  }

  @override
  void initState() {
    _colorValue = widget.household.color.toDouble();
    _nameController.text = widget.household.name;
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
              hintText: "Household name", hintStyle: TextStyle(color: Colors.white)),
          style: const TextStyle(color: Colors.white),
          onEditingComplete: () {
            editHousehold();
          },
        ),
        Slider(
          value: _colorValue,
          min: 0,
          max: 360,
          onChanged: (double value) {
            setState(() {
              _colorValue = value;
            });
          },
          onChangeEnd: (double value) {
            setState(() {
              _colorValue = value;
            });

            editHousehold();
          },
        ),
      ],
    );
  }
}

class EditUsers extends StatefulWidget {
  const EditUsers({super.key});

  @override
  State<EditUsers> createState() => _EditUsersState();
}

class _EditUsersState extends State<EditUsers> {
  @override
  Widget build(BuildContext context) {
    final _futureUsers = getUsers();

    return FutureBuilder<List<Profile>>(future: null, builder: (BuildContext context, AsyncSnapshot<List<Profile>> snapshot) {
      return const SizedBox();
    });
  }
}

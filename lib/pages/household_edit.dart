import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../households.dart';
import '../http_request.dart';
import '../profile.dart';
import '../session.dart';

class HouseholdEditPage extends StatefulWidget {
  const HouseholdEditPage({super.key, required this.id});

  final int id;

  @override
  State<HouseholdEditPage> createState() => _HouseholdEditPageState();
}

class _HouseholdEditPageState extends State<HouseholdEditPage> {
  Future<Household?> getHouseholdIfAdmin(String? sessionId, int householdId) async {
    final response = await sendApiRequest(
      "/household/check_admin",
      {"session_id": sessionId, "household_id": householdId},
    );

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
            body: const Center(child: CircularProgressIndicator(color: Colors.white)),
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
    sendApiRequest("/household/update", {
      "session_id": Session().getSessionId(),
      "household_id": widget.household.id,
      "new_name": _nameController.text,
      "new_color": _colorValue
    });
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
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
                hintText: "Household name", hintStyle: TextStyle(color: Colors.white)),
            style: const TextStyle(color: Colors.white),
            onEditingComplete: () {
              if (_nameController.text == "") {
                setState(() {
                  _nameController.text = widget.household.name;
                });
              }
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
            thumbColor: HSLColor.fromAHSL(1, _colorValue, 0.83, 0.62).toColor(),
            activeColor: Colors.white70,
            inactiveColor: Colors.white70,
          ),
          EditUsers(household: widget.household)
        ],
      ),
    );
  }
}

class EditUsers extends StatefulWidget {
  const EditUsers({super.key, required this.household});

  final Household household;

  @override
  State<EditUsers> createState() => _EditUsersState();
}

class _EditUsersState extends State<EditUsers> {
  Future<List<Profile>>? _futureUsers;

  @override
  void initState() {
    _futureUsers = widget.household.getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _futureUsers = widget.household.getUsers();

    return FutureBuilder<List<Profile>>(
      future: _futureUsers,
      builder: (BuildContext context, AsyncSnapshot<List<Profile>> snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator(color: Colors.white);
        }

        final users = snapshot.data!;
        return ChangeNotifierProvider<MembersStorage>(
            create: (BuildContext context) =>
                MembersStorage(users: users, householdId: widget.household.id),
            child: Consumer<MembersStorage>(
                builder: (context, MembersStorage membersStorage, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: membersStorage.users
                    .map((user) =>
                        UserSettings(user: user, membersStorage: membersStorage))
                    .toList(),
              );
            }));
      },
    );
  }
}

class UserSettings extends StatefulWidget {
  const UserSettings({super.key, required this.user, required this.membersStorage});

  final Profile user;
  final MembersStorage membersStorage;

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  String _selectedPermission = "";

  @override
  void initState() {
    setState(() {
      _selectedPermission = widget.user.permission!;
    });
    super.initState();
  }

  Future<void> kickUser() async {
    widget.membersStorage.kickUser(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              widget.user.username,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        DropdownMenu<String>(
          dropdownMenuEntries: ["member", "admin"]
              .map<DropdownMenuEntry<String>>(
                  (String value) => DropdownMenuEntry<String>(value: value, label: value))
              .toList(),
          initialSelection: widget.user.permission,
          onSelected: (String? value) {
            setState(() {
              _selectedPermission = value!;
            });
            widget.membersStorage.editPermission(widget.user, _selectedPermission);
          },
          textStyle: const TextStyle(color: Colors.white),
        ),
        TextButton(
            onPressed: () {
              kickUser();
            },
            child: const Text(
              "Kick",
              style: TextStyle(color: Colors.red),
            ))
      ],
    );
  }
}

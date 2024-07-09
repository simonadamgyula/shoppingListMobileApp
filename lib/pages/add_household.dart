import 'package:ShopMate/session.dart';
import 'package:flutter/material.dart';

import '../households.dart';

class AddHouseholdPage extends StatelessWidget {
  const AddHouseholdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF2F3C42),
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Login",
            style:
                TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF2F3C42),
        ),
        body: const Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            children: [CreateForm(), JoinForm()],
          ),
        ));
  }
}

class CreateForm extends StatefulWidget {
  const CreateForm({super.key});

  @override
  State<CreateForm> createState() => _CreateFormState();
}

class _CreateFormState extends State<CreateForm> {
  final TextEditingController nameController = TextEditingController();
  bool loading = false;
  double _colorValue = 0;
  String? error;

  @override
  Widget build(BuildContext context) {
    final session = Session();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2F3C42),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 30.0,
            offset: Offset(0, 5),
          ),
        ]
      ),
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.all(10),
      child: Form(
        child: Column(
          children: [
            const Text(
              "Create new household",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: "Name", labelStyle: TextStyle(color: Colors.white)),
              style: const TextStyle(color: Colors.white),
              controller: nameController,
            ),
            Slider(
              value: _colorValue,
              min: 0,
              max: 360.0,
              onChanged: (double value) {
                setState(() {
                  _colorValue = value;
                });
              },
              thumbColor: HSLColor.fromAHSL(1, _colorValue, 0.83, 0.62).toColor(),
              activeColor: Colors.white70,
              inactiveColor: Colors.white70,
            ),
            TextButton(
              onPressed: () {
                if (loading) return;
                setState(() {
                  loading = true;
                });
                createHousehold(
                        session.getSessionId(), nameController.text, _colorValue.round())
                    .then((result) {
                  setState(() {
                    loading = false;
                  });
                  if (result) {
                    Navigator.pop(context, true);
                    return;
                  }

                  setState(() {
                    error = "Failed to create household";
                  });
                });
              },
              child: Text(
                loading ? "loading..." : "Crete",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            (error != null)
                ? Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}

class JoinForm extends StatefulWidget {
  const JoinForm({super.key});

  @override
  State<JoinForm> createState() => _JoinFormState();
}

class _JoinFormState extends State<JoinForm> {
  final TextEditingController codeController = TextEditingController();
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final session = Session();

    return Container(
      decoration: const BoxDecoration(
          color: Color(0xFF2F3C42),
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 50.0,
              offset: Offset(0, 5),
            ),
          ]
      ),
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.all(10),
      child: Form(
        child: Column(
          children: [
            const Text(
              "Join existing household",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Join code",
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
              controller: codeController,
            ),
            TextButton(
              onPressed: () {
                if (loading) return;
                setState(() {
                  loading = true;
                });
                joinHousehold(session.getSessionId(), codeController.text).then((result) {
                  setState(() {
                    loading = false;
                  });
                  if (result) {
                    Navigator.pop(context, true);
                    return;
                  }

                  setState(() {
                    error = "Wrong join code";
                  });
                });
              },
              child: Text(
                loading ? "loading..." : "Join",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            (error != null)
                ? Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}

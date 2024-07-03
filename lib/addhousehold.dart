import 'package:flutter/material.dart';

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
        body: const Column(
          children: [
            CreateForm(),
            JoinForm()
          ],
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
  double _colorValue = 0;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          const Text("Create new household"),
          TextFormField(
            decoration: const InputDecoration(
                labelText: "Name", labelStyle: TextStyle(color: Colors.white)),
            style: const TextStyle(color: Colors.white),
            controller: nameController,
          ),
          Slider(
              value: _colorValue,
              max: 360.0,
              onChanged: (double value) {
                setState(() {
                  _colorValue = value;
                });
              }),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          const Text("Join existing household"),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Join code", labelStyle: TextStyle(color: Colors.white),
            ),
            style: const TextStyle(color: Colors.white),
            controller: codeController,
          )
        ],
      ),
    );
  }
}

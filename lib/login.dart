import 'dart:convert';
import 'dart:developer';

import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:session_storage/session_storage.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
        body: const LoginForm());
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<_LoginFormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<String?> logIn() async {
    final response = await http.post(
        Uri.parse("http://192.168.1.93:8001/user/authenticate"),
        headers: {
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "username": usernameController.text,
          "password": passwordController.text
        }));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body["session_id"];
    }

    return null;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionStorage();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
                labelText: "Username", labelStyle: TextStyle(color: Colors.white)),
            style: const TextStyle(color: Colors.white),
            controller: usernameController,
          ),
          TextFormField(
            decoration: const InputDecoration(
                labelText: "Password", labelStyle: TextStyle(color: Colors.white)),
            style: const TextStyle(color: Colors.white),
            controller: passwordController,
          ),
          TextButton(
              onPressed: () {
                logIn().then(
                    (result) {
                      if (result != null) {
                        log(result);
                        session["session_id"] = result;
                        loginNotifier.value = result;
                      }
                    });
              },
              child: const Text("Log in"))
        ],
      ),
    );
  }
}

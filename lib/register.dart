import 'dart:convert';
import 'dart:developer';

import 'package:app/login.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF2F3C42),
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Register",
            style:
                TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF2F3C42),
        ),
        body: const RegisterForm());
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();

  Future<String?> register() async {
    var response = await http.post(
        Uri.parse("http://192.168.1.93:8001/user/new"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"username": usernameController.text, "password": passwordController.text, "profile_picture": ""}));

    if (response.statusCode != 200) {
      return null;
    }

    response = await http.post(Uri.parse("http://192.168.1.93:8001/user/authenticate"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"username": usernameController.text, "password": passwordController.text}));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body["session_id"];
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: usernameController,
            decoration: const InputDecoration(
                labelText: "Username", labelStyle: TextStyle(color: Colors.white)),
          ),
          TextFormField(
            controller: passwordController,
            decoration: const InputDecoration(
                labelText: "Password", labelStyle: TextStyle(color: Colors.white)),
          ),
          TextFormField(
            controller: rePasswordController,
            decoration: const InputDecoration(
                labelText: "Repeat password", labelStyle: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              register().then((result) {
                log(result ?? "null");
                if (result != null) {
                  Navigator.pop(context, result);
                }
              });
            },
            child: const Text("Register"),
          ),
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(text: "Already have an account? "),
                TextSpan(
                    text: "Log in!",
                    style: const TextStyle(color: Colors.blueAccent),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()));
                      })
              ],
            ),
          ),
        ],
      ),
    );
  }
}

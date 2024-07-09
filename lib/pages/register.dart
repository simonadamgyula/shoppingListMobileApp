import 'dart:convert';
import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../http_request.dart';
import 'login.dart';

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
  late FocusNode passwordNode;
  late FocusNode rePasswordNode;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();

  String? error;

  @override
  void initState() {
    passwordNode = FocusNode();
    rePasswordNode = FocusNode();

    super.initState();
  }

  Future<String?> register() async {
    if (passwordController.text != rePasswordController.text) {
      setState(() {
        error = "Passwords do not match";
      });
      return null;
    }
    if (passwordController.text.isEmpty || usernameController.text.isEmpty) {
      setState(() {
        error = "Username and password must not be empty";
      });
      return null;
    }

    var response = await sendApiRequest(
      "/user/new",
      {
        "username": usernameController.text,
        "password": passwordController.text,
        "profile_picture": ""
      },
    );

    if (response.statusCode != 200) {
      return null;
    }

    response = await sendApiRequest(
      "/user/authenticate",
      {"username": usernameController.text, "password": passwordController.text},
    );

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
            style: const TextStyle(color: Colors.white),
            onFieldSubmitted: (String _) {
              passwordNode.requestFocus();
            },
            maxLength: 20,
          ),
          TextFormField(
            controller: passwordController,
            decoration: const InputDecoration(
                labelText: "Password", labelStyle: TextStyle(color: Colors.white)),
            style: const TextStyle(color: Colors.white),
            onFieldSubmitted: (String _) {
              rePasswordNode.requestFocus();
            },
          ),
          TextFormField(
            controller: rePasswordController,
            decoration: const InputDecoration(
                labelText: "Repeat password", labelStyle: TextStyle(color: Colors.white)),
            style: const TextStyle(color: Colors.white),
            onFieldSubmitted: (_) {
              register().then((result) {
                if (result != null) {
                  Navigator.pop(context, result);
                }
              });
            },
          ),
          (error != null)
              ? Text(
                  error!,
                  style: const TextStyle(color: Colors.red),
                )
              : const SizedBox(),
          TextButton(
            onPressed: () {
              register().then((result) {
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
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => const LoginPage()));
                      })
              ],
            ),
          ),
        ],
      ),
    );
  }
}

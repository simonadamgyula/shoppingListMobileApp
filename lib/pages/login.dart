import 'dart:convert';

import 'package:ShopMate/pages/register.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../http_request.dart';

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

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? error;

  late FocusNode _passwordFocusNode;

  Future<void> logIn() async {
    final response = await sendApiRequest(
      "/user/authenticate",
      {"username": usernameController.text, "password": passwordController.text},
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      setState(() {
        error = "Invalid username or password";
      });
      return;
    }

    final body = jsonDecode(response.body);
    final sessionId = body["session_id"];

    if (mounted) {
      Navigator.pop(context, sessionId);
    }
  }

  @override
  void initState() {
    _passwordFocusNode = FocusNode();

    super.initState();
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
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
                labelText: "Username", labelStyle: TextStyle(color: Colors.white)),
            style: const TextStyle(color: Colors.white),
            controller: usernameController,
            autofocus: true,
            onFieldSubmitted: (String value) {
              _passwordFocusNode.requestFocus();
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
                labelText: "Password", labelStyle: TextStyle(color: Colors.white)),
            style: const TextStyle(color: Colors.white),
            controller: passwordController,
            focusNode: _passwordFocusNode,
            onFieldSubmitted: (String value) {
              logIn();
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
                logIn();
              },
              child: const Text("Log in")),
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(text: "Don't have an account yet? "),
                TextSpan(
                    text: "Register!",
                    style: const TextStyle(color: Colors.blueAccent),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterPage()));
                      })
              ],
            ),
          ),
        ],
      ),
    );
  }
}

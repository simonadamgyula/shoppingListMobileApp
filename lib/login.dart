import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
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

  Future<bool> logIn() async {
    log("log in");
    final response = await http.post(
        Uri.parse("http://192.168.1.93:8001/user/authenticate"),
        body: jsonDecode(
            '{"username": "${usernameController.text}", "password": "${passwordController.text}"}'));

    log("something");

    if (response.statusCode == 200) {
      return true;
    }

    return false;
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
                    (success) {log("$success ysdfas");});
              },
              child: const Text("Log in"))
        ],
      ),
    );
  }
}

import 'dart:convert';

import 'package:guardianwallet/guardianmenu.dart'; // Make sure this import matches the location of your file


import 'package:flutter/material.dart';
import 'package:guardianwallet/tokenmanager.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/v1/public/login'),
      body: {
        'email': _emailController.text,
        'password': _passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      // Store bearer token for the session
      final token = json.decode(response.body)['token'];
      await SecureSessionManager.setToken(token);
      // Navigate to the next screen or perform other actions

      // Add this to navigate to the GuardianMenuPage after login
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => GuardianMenuPage(),
      ));

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              // In login_screen.dart
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },

            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              // In login_screen.dart
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },

              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                  _login();
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

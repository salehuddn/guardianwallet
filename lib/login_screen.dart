import 'dart:convert';

import 'guardianmenu.dart'; // Make sure this import matches the location of your file


import 'package:flutter/material.dart';
import 'tokenmanager.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

import 'dependentmenu.dart';

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
      Uri.parse('$BASE_API_URL/public/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      // print('Response Body: ${response.body}');
      final data = json.decode(response.body);
      final token = data['token'];
      final role = data['role']; // The role is a single string.
      await SecureSessionManager.setToken(token);

      // Check the user's role and navigate accordingly.
      if (role == 'guardian') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => GuardianMenuPage(),
        ));
      } else {
        // Assuming any other role is a dependent for now.
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => DependentMenuPage(),
        ));
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
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

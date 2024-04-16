import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tokenmanager.dart'; // Assuming you have this file set up for token management.

class CreateDependentPage extends StatefulWidget {
  @override
  _CreateDependentPageState createState() => _CreateDependentPageState();
}

class _CreateDependentPageState extends State<CreateDependentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  Future<void> _registerDependent() async {
    final token = await SecureSessionManager.getToken(); // Get the token for the session
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/v1/secured/guardian/create-dependant'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'date_of_birth': _dateOfBirthController.text,
      }),
    );

    if (response.statusCode == 201) {
      // Dependent creation was successful
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dependent Successfully Created!')),
      );
      // You may want to navigate away or reset the form
    } else {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create dependent')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Dependent'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateOfBirthController,
                decoration: InputDecoration(labelText: 'Date of Birth'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the date of birth.';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _registerDependent();
                  }
                },
                child: Text('Register Dependent'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

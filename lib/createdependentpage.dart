import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'bottomappbar.dart';
import 'tokenmanager.dart'; // Assuming you have this file set up for token management.
import 'constants.dart';

class CreateDependentPage extends StatefulWidget {
  const CreateDependentPage({super.key});

  @override
  _CreateDependentPageState createState() => _CreateDependentPageState();
}

class _CreateDependentPageState extends State<CreateDependentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateOfBirthController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _registerDependent() async {
    final token = await SecureSessionManager.getToken(); // Get the token for the session
    final response = await http.post(
      Uri.parse('$BASE_API_URL/secured/guardian/create-dependant'),
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
    print('Response Body: ${response.body}');
    if (response.statusCode == 201) {
      // Dependent creation was successful
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dependent Successfully Created!')),
      );
      // You may want to navigate away or reset the form
    } else {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create dependent')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Dependent'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
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
                readOnly: true,
                decoration: InputDecoration(
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                  labelText: 'Date of Birth (Must be under 18)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.grey),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your date of birth';
                  }
                  return null;
                },
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _registerDependent();
                  }
                },
                child: const Text('Register Dependent'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomAppBar(currentIndex: 3), // Use an appropriate index
    );
  }
}

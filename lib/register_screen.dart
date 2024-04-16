import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatelessWidget {
  static const routeName = '/register';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  Future<void> _register() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/v1/public/register'),
      body: {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'date_of_birth': _dobController.text,
      },
    );

    if (response.statusCode == 201) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Congratulations!'),
            content: Text('You have been registered.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: Text('Done'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Failed')),
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
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              obscureText: true,
            ),
            TextFormField(
              controller: _dobController,
              decoration: InputDecoration(labelText: 'Date of Birth (YY-MM-DD)'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your date of birth. Format: yy-mm-dd';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                  _register();
                }
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

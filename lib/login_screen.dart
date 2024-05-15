import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'guardianmenu.dart';  // Ensure these paths are correct
import 'dependentmenu.dart';
import 'tokenmanager.dart';
import 'constants.dart';
import 'register_screen.dart';  // Assuming this import path is correct

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),  // Title added
        leading: IconButton(

          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A2833)),  // Correctly formatted back button color
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,  // Blends with the background
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: SingleChildScrollView(
            child: LoginForm(),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

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
      final data = json.decode(response.body);
      final token = data['token'];
      final role = data['role'];
      await SecureSessionManager.setToken(token);
      if (role == 'guardian') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const GuardianMenuPage()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const DependentMenuPage()));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Image.asset('assets/icon/logo_gw.png', height: 120),
            const SizedBox(height: 48),
            // Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                labelText: 'Email/Phone Number',
                labelStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.person, color: Colors.white),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email or phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.lock, color: Colors.white),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                  _login();
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,  // Text color
                backgroundColor: Colors.white,  // Button background color
                padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 90),  // Increased padding
                textStyle: const TextStyle(fontSize: 18),  // Text style remains the same
                elevation: 4,  // Added shadow/elevation
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),  // Smaller border radius
              ),
              child: const Text('Login'),

            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, RegisterScreen.routeName);
              },
              child: const Text('Don\'t have an account yet? Sign Up', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Add intl package for date formatting
import 'constants.dart';
import 'login_screen.dart'; // Ensure the path is correct

class RegisterScreen extends StatelessWidget {
  static const routeName = '/register';

  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Register', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Color(0xFF1A2833)),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      // ),
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
            child: RegisterForm(),
          ),
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  Future<void> _presentDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked); // Update the text of the controller with the formatted date
      });
    }
  }

  Future<void> _register() async {
    final response = await http.post(
      Uri.parse('$BASE_API_URL/public/register'),
      body: {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'date_of_birth': _dobController.text,
      },
    );

    if (response.statusCode == 201) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        headerAnimationLoop: false,
        title: 'Congratulations!',
        desc: 'You have been registered.',
        btnOkOnPress: () {
          Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
        },
        btnOkText: 'Done',
        btnOkIcon: Icons.check_circle,
      ).show();
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        headerAnimationLoop: false,
        title: 'Registration Failed',
        desc: 'Please try again.',
        btnOkOnPress: () {},
        btnOkText: 'OK',
        btnOkIcon: Icons.cancel,
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 7),
            Image.asset('assets/icon/logo_gw.png', height: 150),
            const SizedBox(height: 48),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.person, color: Colors.white),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.email, color: Colors.white),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
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
                labelText: 'Password (Min. 8 chracters',
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
            const SizedBox(height: 20),
            TextFormField(
              controller: _dobController,
              readOnly: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                labelText: 'Date of Birth (Must be over 18)',
                labelStyle: const TextStyle(color: Colors.white),
                prefixIcon: const Icon(Icons.calendar_today, color: Colors.white),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: _presentDatePicker,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your date of birth ';
                }
                return null;
              },
              onTap: _presentDatePicker,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                  _register();
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 90),
                textStyle: const TextStyle(fontSize: 18),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Register'),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.routeName);
              },
              child: const Text('Already have an account? Sign in', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}

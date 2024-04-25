import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tokenmanager.dart';

class GuardianProfilePage extends StatefulWidget {
  @override
  _GuardianProfilePageState createState() => _GuardianProfilePageState();
}

class _GuardianProfilePageState extends State<GuardianProfilePage> {
  bool isLoading = true;
  Map<String, dynamic> profileData = {};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final token = await SecureSessionManager.getToken();
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/v1/secured/guardian/profile'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        profileData = json.decode(response.body)['user'];
        isLoading = false;
      });
    } else {
      // Handle errors
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile data')),
      );
    }
  }

  Future<void> _updateProfile(String key, String value) async {
    final token = await SecureSessionManager.getToken();
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/v1/secured/guardian/update-profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({key: value}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      _fetchProfile();
    } else {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  void _showEditDialog(String key, String title, String currentValue) {
    TextEditingController _controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: title,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your $title';
                }
                return null;
              },
              obscureText: key == 'password', // Obscure text if editing password
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _updateProfile(key, _controller.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  TableRow _buildTableRow(String title, String value, String key) {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(title),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(value),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _showEditDialog(key, title, value),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guardian Profile'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(),
            1: FlexColumnWidth(),
            2: FixedColumnWidth(48.0),
          },
          children: [
            _buildTableRow('Name', profileData['name'] ?? 'N/A', 'name'),
            _buildTableRow('Email', profileData['email'] ?? 'N/A', 'email'),
            _buildTableRow('Phone Number', profileData['phone'] ?? 'N/A', 'phone'),
            _buildTableRow('Date of Birth', profileData['dob']?.substring(0, 10) ?? 'N/A', 'dob'),
            _buildTableRow('Password', '********', 'password'), // Display obscured password
          ],
        ),
      ),
    );
  }
}

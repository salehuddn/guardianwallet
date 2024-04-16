import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tokenmanager.dart';  // Assuming this handles your token storage

class GuardianProfilePage extends StatefulWidget {
  @override
  _GuardianProfilePageState createState() => _GuardianProfilePageState();
}

class _GuardianProfilePageState extends State<GuardianProfilePage> {
  bool isLoading = true;
  Map<String, dynamic> profileData = {};

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guardian Profile'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          Text('Name: ${profileData['name'] ?? 'N/A'}'),
          Text('Email: ${profileData['email'] ?? 'N/A'}'),
          Text('Phone Number: ${profileData['phone'] ?? 'N/A'}'), // Ensure your API sends this data
          Text('Date of Birth: ${profileData['dob']?.substring(0, 10) ?? 'N/A'}'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to Edit Profile Page
            },
            child: Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
}

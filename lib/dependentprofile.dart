import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tokenmanager.dart'; // Assumed necessary for token
import 'constants.dart';

class DependentProfilePage extends StatefulWidget {
  const DependentProfilePage({super.key});

  @override
  _DependentProfilePageState createState() => _DependentProfilePageState();
}

class _DependentProfilePageState extends State<DependentProfilePage> {
  bool isLoading = true;
  Map<String, dynamic> profileData = {};

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _logout() async {
    final token = await SecureSessionManager.getToken();
    final response = await http.post(
      Uri.parse('$BASE_API_URL/secured/logout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print('Response Body: ${response.body}');
    if (response.statusCode == 200) {
      SecureSessionManager.deleteToken();
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to logout')),
      );
    }
  }

  Future<void> _fetchProfile() async {
    final token = await SecureSessionManager.getToken(); // Fetch the authentication token
    final response = await http.get(
      Uri.parse('$BASE_API_URL/secured/dependant/profile'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Fetched Profile Data: $data'); // Debug logging
      setState(() {
        profileData = data['user'];
        isLoading = false;
      });
    } else {
      // Handle errors
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile')),
      );
    }
  }

  Widget _buildProfileDetails() {
    return Table(
      border: TableBorder.all(width: 1.0, color: Colors.grey),
      children: [
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(profileData['name'] ?? 'N/A'),
            ),
          ],
        ),
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(profileData['email'] ?? 'N/A'),
            ),
          ],
        ),
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(profileData['dob']?.substring(0, 10) ?? 'N/A'),
            ),
          ],
        ),
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(profileData['phone'] ?? 'N/A'),
            ),
          ],
        ),
        // TableRow(
        //   children: [
        //     const Padding(
        //       padding: EdgeInsets.all(8.0),
        //       child: Text('Spending Limit (RM)', style: TextStyle(fontWeight: FontWeight.bold)),
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: Text(profileData['spending_limit']?.toString() ?? 'N/A'), // Ensure spending_limit is converted to String
        //     ),
        //   ],
        // ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dependent Profile'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildProfileDetails(),
        ),
      ),
    );
  }
}

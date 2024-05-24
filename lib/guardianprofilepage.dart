import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tokenmanager.dart';
import 'constants.dart';
import 'bottomappbar.dart';

class GuardianProfilePage extends StatefulWidget {
  const GuardianProfilePage({super.key});

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
      Uri.parse('$BASE_API_URL/secured/guardian/profile'),
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
        const SnackBar(content: Text('Failed to load profile data')),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardian Profile'),
        automaticallyImplyLeading: false, // Remove the back button
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16),
              _buildProfileField(Icons.person, 'Name', profileData['name'] ?? 'N/A', 'name'),
              _buildProfileField(Icons.email, 'Email', profileData['email'] ?? 'N/A', 'email'),
              _buildProfileField(Icons.phone, 'Phone Number', profileData['phone'] ?? 'N/A', 'phone'),
              _buildProfileField(Icons.cake, 'Date of Birth', profileData['dob']?.substring(0, 10) ?? 'N/A', 'dob'),
              _buildProfileField(Icons.lock, 'Password', '********', 'password'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomAppBar(currentIndex: 4),
    );
  }

  Widget _buildProfileField(IconData icon, String title, String value, String key) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => _showEditDialog(key, title, value),
        ),
      ),
    );
  }

  void _showEditDialog(String key, String title, String currentValue) {
    TextEditingController controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: title,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateProfile(key, controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProfile(String key, String value) async {
    final token = await SecureSessionManager.getToken();
    final response = await http.post(
      Uri.parse('$BASE_API_URL/secured/guardian/update-profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        key: value,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      _fetchProfile();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }
}

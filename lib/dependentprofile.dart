import 'package:flutter/material.dart';
import 'package:guardianwallet/dependentpayment.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dependentmenu.dart';
import 'tokenmanager.dart';
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

  Widget _buildProfileField(IconData icon, String title, String value, String key) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
        // trailing: IconButton(
        //   icon: Icon(Icons.edit),
        //   onPressed: () => _showEditDialog(key, title, value),
        // ),
      ),
    );
  }


  Widget _buildProfileDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 16),
        _buildProfileField(Icons.person, 'Name', profileData['name'] ?? 'N/A', 'name'),
        _buildProfileField(Icons.email, 'Email', profileData['email'] ?? 'N/A', 'email'),
        _buildProfileField(Icons.cake, 'Date of Birth', profileData['dob']?.substring(0, 10) ?? 'N/A', 'dob'),
        _buildProfileField(Icons.phone, 'Phone', profileData['phone'] ?? 'N/A', 'phone'),
        _buildProfileField(Icons.warning, 'Spending Limit', profileData['spending_limit'] ?? 'N/A', 'spending_limit'),
      ],
    );
  }

  void _selectPage(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DependentMenuPage(currentIndex: index)));
        break;
      case 1:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DependentProfilePage()));
        break;
      case 3:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DependentPaymentPage()));
        break;
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildIconButton(Icons.home, 0),
          const Spacer(),
          _buildIconButton(Icons.qr_code_scanner, 3, isFloating: true),
          const Spacer(),
          _buildIconButton(Icons.account_circle, 1),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, int index, {bool isFloating = false}) {
    return IconButton(
      icon: Icon(icon, color: index == 1 ? Colors.blue : Colors.black), // Highlight the current page icon
      iconSize: isFloating ? 30.0 : 24.0,
      onPressed: () => _selectPage(index),
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
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}

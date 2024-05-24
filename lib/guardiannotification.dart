import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Add this line
import 'tokenmanager.dart';
import 'constants.dart';

class GuardianNotificationPage extends StatefulWidget {
  const GuardianNotificationPage({super.key});

  @override
  _GuardianNotificationPageState createState() => _GuardianNotificationPageState();
}

class _GuardianNotificationPageState extends State<GuardianNotificationPage> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final token = await SecureSessionManager.getToken();
    final response = await http.get(
      Uri.parse('$BASE_API_URL/secured/notifications'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print("HTTP response code: ${response.statusCode}");
    print("HTTP response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        notifications = data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load notifications')),
      );
    }
  }

  String _formatTimestamp(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp).toUtc();
    final DateTime kualaLumpurTime = dateTime.add(Duration(hours: 8)); // Kuala Lumpur is UTC+8
    final DateFormat formatter = DateFormat('dd/MM/yy HH:mm');
    return formatter.format(kualaLumpurTime);
  }

  Widget _buildNotificationPanel(dynamic notification) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${notification['data']['title']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(notification['data']['message']),
            const SizedBox(height: 8.0),
            Text(
              'Received at: ${_formatTimestamp(notification['created_at'])}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationPanel(notifications[index]);
        },
      ),
    );
  }
}

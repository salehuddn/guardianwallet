import 'package:flutter/material.dart';
import 'package:guardianwallet/guardiannotification.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'createdependentpage.dart';
import 'guardianprofilepage.dart';
import 'managedependent.dart';
import 'tokenmanager.dart';
import 'transactionhistory.dart';
import 'transferfunddependent.dart';
import 'topupwallet.dart';
import 'constants.dart';
import 'bottomappbar.dart';
import 'dependentanalytic.dart'; // Import the new page

class GuardianMenuPage extends StatefulWidget {
  final int currentIndex;
  const GuardianMenuPage({super.key, this.currentIndex = 0}); // Set the home page as default

  @override
  _GuardianMenuPageState createState() => _GuardianMenuPageState();
}

class _GuardianMenuPageState extends State<GuardianMenuPage> {
  double _balance = 0.0;
  bool _balanceVisible = false;
  String _userName = "Loading..."; // Default text while loading
  List<Map<String, dynamic>> _latestTransactions = [];
  List<dynamic> _latestNotifications = [];

  @override
  void initState() {
    super.initState();
    _fetchWalletBalance();
    _fetchLatestTransactions();
    _fetchLatestNotifications();
  }

  void _fetchWalletBalance() async {
    final token = await SecureSessionManager.getToken();
    final walletResponse = await http.get(
      Uri.parse('$BASE_API_URL/secured/guardian/wallet'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final profileResponse = await http.get(
      Uri.parse('$BASE_API_URL/secured/guardian/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (walletResponse.statusCode == 200 && profileResponse.statusCode == 200) {
      final walletData = json.decode(walletResponse.body);
      final profileData = json.decode(profileResponse.body);
      setState(() {
        _balance = double.tryParse(walletData['wallet']['balance']) ?? 0.0;
        _userName = profileData['user']['name']; // Assuming the user's name is under the 'user' key
      });
    } else {
      // Handle errors
      print('Error fetching wallet balance: ${walletResponse.body}');
      print('Error fetching profile data: ${profileResponse.body}');
    }
  }

  Future<void> _fetchLatestTransactions() async {
    final token = await SecureSessionManager.getToken();
    final response = await http.get(
      Uri.parse('$BASE_API_URL/secured/guardian/transaction-history'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Transaction Data: $data'); // Debugging line

      if (data['transactions'] != null && data['transactions'].isNotEmpty) {
        final transactions = List<Map<String, dynamic>>.from(data['transactions']);
        setState(() {
          // We take the latest three transactions or less if not enough transactions
          _latestTransactions = transactions.take(3).toList();
        });
      } else {
        // If there are no transactions, we clear the list to trigger the "No transactions" message
        setState(() {
          _latestTransactions.clear();
        });
      }
    } else {
      // If the call was not successful, print the response for debugging
      print('Error fetching transactions: ${response.body}');
    }
  }

  Future<void> _fetchLatestNotifications() async {
    final token = await SecureSessionManager.getToken();
    final response = await http.get(
      Uri.parse('$BASE_API_URL/secured/notifications'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _latestNotifications = data.take(3).toList();
      });
    } else {
      print('Error fetching notifications: ${response.body}');
    }
  }

  Future<void> _markNotificationAsRead(String notificationId) async {
    final token = await SecureSessionManager.getToken();
    final response = await http.post(
      Uri.parse('$BASE_API_URL/secured/notifications/$notificationId/read'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      print('Error marking notification as read: ${response.body}');
    }
  }

  Widget _buildBalanceInfo() {
    return Stack(
      clipBehavior: Clip.none, // Ensures the overflow is visible
      children: [
        Image.asset(
          'assets/img/guardianmenubg.png',
          width: double.infinity,
          height: 187,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 40,
          left: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $_userName',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    _balanceVisible ? 'RM${_balance.toStringAsFixed(2)}' : '*******',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _balanceVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _balanceVisible = !_balanceVisible;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 40,
          right: 16,
          child: IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const GuardianProfilePage(),
              ));
            },
          ),
        ),
        Positioned(
          bottom: -50, // Adjust this value to position the menu correctly
          left: 0,
          right: 0,
          child: _buildQuickMenu(),
        ),
      ],
    );
  }

  Widget _buildQuickMenu() {
    return Card(
      margin: const EdgeInsets.all(15.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _quickMenuButton(Icons.swap_vert, 'Allocate Fund', () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const TransferFundDependentPage(),
              ));
            }),
            _quickMenuButton(Icons.person, 'Create Dependent', () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const CreateDependentPage(),
              ));
            }),
            _quickMenuButton(Icons.analytics, 'Analytics', () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const DependentAnalyticPage(),
              ));
            }),
          ],
        ),
      ),
    );
  }

  Widget _quickMenuButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon: Icon(icon),
          onPressed: onTap,
        ),
        Text(label),
      ],
    );
  }

  Widget _buildNotificationsPanel() {
    return Card(
      margin: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications for the account'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const GuardianNotificationPage(),
              ));
            },
          ),
          if (_latestNotifications.isNotEmpty)
            Column(
              children: _latestNotifications.map((notification) {
                return ListTile(
                  leading: const Icon(Icons.notification_important),
                  title: Text(notification['data']['title']),
                  subtitle: Text(notification['data']['message']),
                  onTap: () async {
                    await _markNotificationAsRead(notification['id']);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const GuardianNotificationPage(),
                    ));
                  },
                );
              }).toList(),
            )
          else
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No recent notifications found.'),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistoryPanel() {
    return Card(
      margin: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Latest Transaction History'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const TransactionHistoryPage(),
              ));
            },
          ),
          if (_latestTransactions.isNotEmpty)
            Column(
              children: _latestTransactions.map((transaction) {
                Color amountColor;
                Icon transactionIcon;
                if (transaction['transaction_type']['name'] == 'Transfer Fund') {
                  amountColor = Colors.red;
                  transactionIcon = Icon(Icons.arrow_upward, color: amountColor);
                } else {
                  amountColor = Colors.green;
                  transactionIcon = Icon(Icons.arrow_downward, color: amountColor);
                }
                return ListTile(
                  leading: transactionIcon,
                  title: Text(transaction['transaction_type']['name']),
                  subtitle: Text('Completed at: ${transaction['completed_at']}'),
                  trailing: Text(
                    'RM${transaction['amount']}',
                    style: TextStyle(color: amountColor),
                  ),
                );
              }).toList(),
            )
          else
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No recent transactions found.'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none, // Ensures the overflow is visible
            children: [
              _buildBalanceInfo(),
            ],
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                SizedBox(height: 10), // Adjust height to ensure the quick menu is visible
                _buildNotificationsPanel(),
                SizedBox(height: 10), // Add spacing to bring the panels closer together
                _buildTransactionHistoryPanel(),
                // Add more widgets as needed
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomAppBar(currentIndex: widget.currentIndex),
    );
  }
}

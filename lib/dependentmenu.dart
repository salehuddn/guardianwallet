import 'package:flutter/material.dart';
import 'package:guardianwallet/guardiannotification.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dependentpayment.dart';
import 'dependentprofile.dart';
import 'dependenthistory.dart';
import 'tokenmanager.dart';
import 'transactionhistory.dart';
import 'constants.dart';

class DependentMenuPage extends StatefulWidget {
  final int currentIndex;

  const DependentMenuPage({super.key, this.currentIndex = 0});

  @override
  _DependentMenuPageState createState() => _DependentMenuPageState();
}

class _DependentMenuPageState extends State<DependentMenuPage> {
  double _balance = 0.0;
  bool _balanceVisible = false;
  String _userName = "Loading...";
  List<Map<String, dynamic>> _latestTransactions = [];
  List<dynamic> _latestNotifications = [];

  void _fetchWalletBalance() async {
    final token = await SecureSessionManager.getToken();
    final walletResponse = await http.get(
      Uri.parse('$BASE_API_URL/secured/dependant/wallet'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final profileResponse = await http.get(
      Uri.parse('$BASE_API_URL/secured/dependant/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (walletResponse.statusCode == 200 && profileResponse.statusCode == 200) {
      final walletData = json.decode(walletResponse.body);
      final profileData = json.decode(profileResponse.body);
      setState(() {
        _balance = double.tryParse(walletData['wallet']['balance'].toString()) ?? 0.0;
        _userName = profileData['user']['name'];
      });
    } else {
      print('Error fetching wallet balance: ${walletResponse.body}');
      print('Error fetching profile data: ${profileResponse.body}');
    }
  }

  Future<void> _fetchLatestTransactions() async {
    final token = await SecureSessionManager.getToken();
    final response = await http.get(
      Uri.parse('$BASE_API_URL/secured/dependant/transaction-history'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['transactions'] != null && data['transactions'].isNotEmpty) {
        final transactions = List<Map<String, dynamic>>.from(data['transactions']);
        setState(() {
          _latestTransactions = transactions.take(3).toList();
        });
      } else {
        setState(() {
          _latestTransactions.clear();
        });
      }
    } else {
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

  @override
  void initState() {
    super.initState();
    _fetchWalletBalance();
    _fetchLatestTransactions();
    _fetchLatestNotifications();
  }

  void _selectPage(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DependentMenuPage(currentIndex: index)));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DependentProfilePage()));
        break;
      case 3:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DependentPaymentPage()));
        break;
    }
  }

  Widget _buildBalanceInfo() {
    return Stack(
      clipBehavior: Clip.none,
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
                builder: (context) => const DependentProfilePage(),
              ));
            },
          ),
        ),
        Positioned(
          bottom: -50,
          left: 0,
          right: 0,
          child: _buildQuickMenu(),
        ),
      ],
    );
  }

  Widget _buildQuickMenu() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _quickMenuButton(Icons.payment, 'Pay', () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const DependentPaymentPage(),
              ));
            }),
            _quickMenuButton(Icons.history, 'Expenses', () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const DependentHistoryPage(),
              ));
            }),
            _quickMenuButton(Icons.account_circle, 'Profile', () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const DependentProfilePage(),
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
      margin: const EdgeInsets.all(8.0),
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
      margin: const EdgeInsets.all(8.0),
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
                return ListTile(
                  title: Text(transaction['transaction_type']['name']),
                  subtitle: Text('Completed at: ${transaction['completed_at']}'),
                  trailing: Text('RM${transaction['amount']}'),
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
      icon: Icon(icon),
      iconSize: isFloating ? 30.0 : 24.0,
      onPressed: () => _selectPage(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Dependent Dashboard'),
      //   automaticallyImplyLeading: false,
      // ),
      body: ListView(
        children: <Widget>[
          _buildBalanceInfo(),
          SizedBox(height: 50), // Adjust the height to ensure the quick menu is visible
          _buildNotificationsPanel(),
          _buildTransactionHistoryPanel(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}

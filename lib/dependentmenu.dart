import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dependentpayment.dart';
import 'dependentprofile.dart'; // Corrected import
import 'dependenthistory.dart'; // Corrected import
import 'tokenmanager.dart';
import 'transactionhistory.dart';
import 'transferfunddependent.dart'; // Assuming this should be included if used
import 'topupwallet.dart'; // Assuming this should be included if used
import 'constants.dart';

class DependentMenuPage extends StatefulWidget {
  final int currentIndex;

  DependentMenuPage({this.currentIndex = 0}); // Set the home page as default

  @override
  _DependentMenuPageState createState() => _DependentMenuPageState();
}

class _DependentMenuPageState extends State<DependentMenuPage> {
  double _balance = 0.0;
  bool _balanceVisible = false;
  String _userName = "Loading..."; // Default text while loading
  List<Map<String, dynamic>> _latestTransactions = [];

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
      Uri.parse('$BASE_API_URL/secured/dependant/transaction-history'),
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

  @override
  void initState() {
    super.initState();
    _fetchWalletBalance();
    _fetchLatestTransactions();
  }

  void _selectPage(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DependentMenuPage(currentIndex: index)));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => DependentProfilePage()));
        break;
      case 3:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => DependentPaymentPage()));
        break;
    }
  }

  Widget _buildBalanceInfo() {
    return ListTile(
      leading: Icon(Icons.account_circle),
      title: Text('Welcome, $_userName'),
      subtitle: Text(_balanceVisible ? 'RM${_balance.toStringAsFixed(2)}' : '*******'),
      trailing: IconButton(
        icon: Icon(_balanceVisible ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            _balanceVisible = !_balanceVisible;
          });
        },
      ),
    );
  }

  Widget _buildQuickMenu() {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _quickMenuButton(Icons.payment, 'Pay', () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DependentProfilePage(),
              ));
            }),
            _quickMenuButton(Icons.history, 'Expenses', () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DependentHistoryPage(),
              ));
            }),
            _quickMenuButton(Icons.account_circle, 'Profile', () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DependentProfilePage(),
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
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(Icons.notifications),
        title: Text('Notifications for the account'),
        onTap: () {
          // Navigate to notifications page
        },
      ),
    );
  }

  Widget _buildTransactionHistoryPanel() {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Latest Transaction History'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TransactionHistoryPage(),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('No recent transactions found.'),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildIconButton(Icons.home, 0), // Home icon
          Spacer(), // Use Spacer to center the middle icon
          _buildIconButton(Icons.qr_code_scanner, 3, isFloating: true), // Elevated QR Pay icon
          Spacer(), // Use Spacer to justify the last icon to the end
          _buildIconButton(Icons.account_circle, 1), // Profile icon
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, int index, {bool isFloating = false}) {
    return IconButton(
      icon: Icon(icon),
      iconSize: isFloating ? 30.0 : 24.0, // Larger icon size for the QR Pay button if it's floating
      onPressed: () => _selectPage(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dependent Dashboard'),
      ),
      body: ListView(
        children: <Widget>[
          _buildBalanceInfo(),
          _buildQuickMenu(),
          _buildTransactionHistoryPanel(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
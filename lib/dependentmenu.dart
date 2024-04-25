import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tokenmanager.dart'; // Handles the token storage

class DependentMenuPage extends StatefulWidget {
  @override
  _DependentMenuPageState createState() => _DependentMenuPageState();
}

class _DependentMenuPageState extends State<DependentMenuPage> {
  String name = '';
  double balance = 0.0;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchDependentData();
  }

  Future<void> _fetchDependentData() async {
    // Fetch profile, wallet, and transactions together
    await _fetchProfile();
    await _fetchWallet();
    await _fetchTransactionHistory();
  }

  Future<void> _fetchProfile() async {
    final token = await SecureSessionManager.getToken();
    final profileResponse = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/v1/secured/dependant/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (profileResponse.statusCode == 200) {
      final profileData = json.decode(profileResponse.body);
      setState(() {
        name = profileData['user']['name'];
      });
    }
  }

  Future<void> _fetchWallet() async {
    final token = await SecureSessionManager.getToken();
    final walletResponse = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/v1/secured/dependant/wallet'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (walletResponse.statusCode == 200) {
      final walletData = json.decode(walletResponse.body);
      setState(() {
        balance = double.tryParse(walletData['wallet']['balance'].toString()) ?? 0.0;
      });
    }
  }

  Future<void> _fetchTransactionHistory() async {
    final token = await SecureSessionManager.getToken();
    final transactionsResponse = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/v1/secured/dependant/transaction-history'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (transactionsResponse.statusCode == 200) {
      final transactionsData = json.decode(transactionsResponse.body);
      setState(() {
        transactions = List<Map<String, dynamic>>.from(transactionsData['transactions']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$name\'s Wallet'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle balance visibility
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Balance: RM$balance', style: Theme.of(context).textTheme.headline6),
                // This would be a toggle button to show/hide balance
                IconButton(
                  icon: Icon(Icons.remove_red_eye),
                  onPressed: () {
                    // Handle show/hide balance
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return ListTile(
                  leading: Icon(Icons.monetization_on), // Icon based on transaction type
                  title: Text(transaction['transaction_type']['name']),
                  subtitle: Text(transaction['completed_at'] ?? 'Pending'),
                  trailing: Text('RM${transaction['amount']}'),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Pay',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        // handle navigation onTap
      ),
    );
  }
}

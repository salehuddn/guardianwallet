import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'createdependentpage.dart';
import 'guardianprofilepage.dart';
import 'tokenmanager.dart';
import 'transactionhistory.dart';
import 'transferfunddependent.dart';
import 'topupwallet.dart';


class GuardianMenuPage extends StatefulWidget {

  final int currentIndex;
  GuardianMenuPage({this.currentIndex = 0}); // Set the home page as default
  @override
  _GuardianMenuPageState createState() => _GuardianMenuPageState();
}

class _GuardianMenuPageState extends State<GuardianMenuPage> {

  double _balance = 0.0;
  bool _balanceVisible = false;
  String _userName = "Loading..."; // Default text while loading
  List<Map<String, dynamic>> _latestTransactions = [];

  void _fetchWalletBalance() async {
    final token = await SecureSessionManager.getToken();
    final walletResponse = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/v1/secured/guardian/wallet'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final profileResponse = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/v1/secured/guardian/profile'),
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
      Uri.parse('http://127.0.0.1:8000/api/v1/secured/guardian/transaction-history'),
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
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => GuardianMenuPage(currentIndex: index)));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => TransactionHistoryPage()));
        break;
      case 3:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => TransferFundDependentPage()));
        break;
      case 4:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => GuardianProfilePage()));
        break;
    // Add additional cases as needed
    }
  }

  Widget _buildBalanceInfo() {
    return ListTile(
      leading: Icon(Icons.account_circle),
      title: Text('Welcome, $_userName'), // Use the dynamic name
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
            _quickMenuButton(Icons.person_add, 'Create Dependent', () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CreateDependentPage(),
              ));
            }),
            _quickMenuButton(Icons.account_balance_wallet, 'Allocate Fund', () {
              // TODO: Navigate to allocate fund page
            }),
            _quickMenuButton(Icons.history, 'History', () {
              // TODO: Navigate to history page
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
                  trailing: Text('Amount: RM${transaction['amount']}'),
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
          _buildIconButton(Icons.home, 0),
          _buildIconButton(Icons.history, 1),
          SizedBox(width: 48), // Placeholder for floating action button
          _buildIconButton(Icons.transfer_within_a_station, 3),
          _buildIconButton(Icons.supervised_user_circle, 4),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, int index) {
    return IconButton(
      icon: Icon(icon),
      color: widget.currentIndex == index ? Colors.blue : Colors.grey,
      onPressed: () => _selectPage(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Replace these with actual values


    return Scaffold(
      appBar: AppBar(
        title: Text('Guardian Dashboard'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => GuardianProfilePage(),
              ));
            },
          ),
        ],
      ),

      body: ListView(
        children: <Widget>[
          _buildBalanceInfo( ),
          _buildQuickMenu(),
          _buildNotificationsPanel(),
          _buildTransactionHistoryPanel(),
          // Add more widgets as needed
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Action for the button
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}

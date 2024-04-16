import 'package:flutter/material.dart';

import 'createdependentpage.dart';
import 'guardianprofilepage.dart';
import 'tokenmanager.dart';


class GuardianMenuPage extends StatefulWidget {
  @override
  _GuardianMenuPageState createState() => _GuardianMenuPageState();
}

class _GuardianMenuPageState extends State<GuardianMenuPage> {
  bool _balanceVisible = false;

  Widget _buildBalanceInfo(String name, double balance) {
    return ListTile(
      leading: Icon(Icons.account_circle),
      title: Text('Welcome, $name'),
      subtitle: Text(_balanceVisible ? '\$${balance.toStringAsFixed(2)}' : '*******'),
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
      child: ListTile(
        leading: Icon(Icons.history),
        title: Text('Latest transaction history'),
        onTap: () {
          // Navigate to transaction history page
        },
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
          IconButton(icon: Icon(Icons.home), onPressed: () {}),
          IconButton(icon: Icon(Icons.history), onPressed: () {}),
          SizedBox(width: 48), // The middle part is for the floating action button
          IconButton(icon: Icon(Icons.transfer_within_a_station), onPressed: () {}),
          IconButton(icon: Icon(Icons.supervised_user_circle), onPressed: () {}),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Replace these with actual values
    final String registeredName = "Guardian";
    final double accountBalance = 1000.00;

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
          _buildBalanceInfo(registeredName, accountBalance),
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

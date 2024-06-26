import 'package:flutter/material.dart';
import 'package:guardianwallet/tokenmanager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'constants.dart';
import 'dependentmenu.dart';
import 'dependentpayment.dart';
import 'dependentprofile.dart';
import 'dependenthistory.dart';
import 'transactionhistory.dart';
import 'guardiannotification.dart';

class DependentTabungPage extends StatefulWidget {
  const DependentTabungPage({Key? key}) : super(key: key);

  @override
  _DependentTabungPageState createState() => _DependentTabungPageState();
}

class _DependentTabungPageState extends State<DependentTabungPage> {
  List<dynamic> _savings = [];

  @override
  void initState() {
    super.initState();
    _fetchSavings();
  }

  Future<void> _fetchSavings() async {
    final token = await SecureSessionManager.getToken();
    final response = await http.get(
      Uri.parse('$BASE_API_URL/secured/dependant/savings/all'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _savings = data['savings'];
      });
    } else {
      print('Error fetching savings: ${response.body}');
    }
  }

  Future<void> _createSavingFund(String name, String goalAmount) async {
    final token = await SecureSessionManager.getToken();
    final response = await http.post(
      Uri.parse('$BASE_API_URL/secured/dependant/savings/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'goal_amount': goalAmount,
      }),
    );

    if (response.statusCode == 201) {
      _fetchSavings();
      Navigator.of(context).pop();
    } else {
      print('Error creating savings fund: ${response.body}');
    }
  }

  Future<void> _updateSavingFund(int id, String name, String goalAmount) async {
    final token = await SecureSessionManager.getToken();
    final response = await http.put(
      Uri.parse('$BASE_API_URL/secured/dependant/savings/update/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'goal_amount': goalAmount,
      }),
    );

    if (response.statusCode == 200) {
      _fetchSavings();
      Navigator.of(context).pop();
    } else {
      print('Error updating savings fund: ${response.body}');
    }
  }

  Future<void> _deleteSavingFund(int id) async {
    final token = await SecureSessionManager.getToken();
    final response = await http.delete(
      Uri.parse('$BASE_API_URL/secured/dependant/savings/delete/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      _fetchSavings();
    } else {
      print('Error deleting savings fund: ${response.body}');
    }
  }

  Future<void> _transferToSavingFund(int savingsId, String amount) async {
    final token = await SecureSessionManager.getToken();
    final response = await http.post(
      Uri.parse('$BASE_API_URL/secured/dependant/savings/transfer'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'savings_id': savingsId,
        'amount': amount,
      }),
    );

    if (response.statusCode == 200) {
      _fetchSavings();
      Navigator.of(context).pop();
    } else {
      print('Error transferring funds: ${response.body}');
    }
  }

  void _showCreateTabungDialog() {
    String name = '';
    String goalAmount = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a Tabung'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Goal Amount'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  goalAmount = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Create'),
              onPressed: () {
                _createSavingFund(name, goalAmount);
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditTabungDialog(int id, String currentName, String currentGoalAmount) {
    String name = currentName;
    String goalAmount = currentGoalAmount;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Tabung'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                controller: TextEditingController(text: currentName),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Goal Amount'),
                controller: TextEditingController(text: currentGoalAmount),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  goalAmount = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Update'),
              onPressed: () {
                _updateSavingFund(id, name, goalAmount);
              },
            ),
          ],
        );
      },
    );
  }

  void _showTopupDialog(int id) {
    String amount = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Top Up Tabung'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amount = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Top Up'),
              onPressed: () {
                _transferToSavingFund(id, amount);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Tabung'),
          content: const Text('Are you sure you want to delete this Tabung?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteSavingFund(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
      appBar: AppBar(
        title: const Text('Tabung Management'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _showCreateTabungDialog,
            child: const Text('Create a Tabung'),
          ),
          _savings.isEmpty
              ? const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No Tabung found. Create one to get started!'),
            ),
          )
              : Expanded(
            child: ListView.builder(
              itemCount: _savings.length,
              itemBuilder: (context, index) {
                final saving = _savings[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(saving['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Goal: RM${saving['goal_amount']}'),
                        Text('Current: RM${saving['amount']}'),
                        Text('Remaining: RM${saving['remaining']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            _showTopupDialog(saving['id']);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditTabungDialog(saving['id'], saving['name'], saving['goal_amount']);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteConfirmationDialog(saving['id']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}

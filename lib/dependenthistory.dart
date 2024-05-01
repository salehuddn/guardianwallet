import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tokenmanager.dart'; // Assuming this manages your token

class DependentHistoryPage extends StatefulWidget {
  @override
  _DependentHistoryPageState createState() => _DependentHistoryPageState();
}

class _DependentHistoryPageState extends State<DependentHistoryPage> {
  List<dynamic> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactionHistory();
  }

  Future<void> _fetchTransactionHistory() async {
    setState(() {
      isLoading = true;  // Set loading state
    });

    final token = await SecureSessionManager.getToken(); // Get auth token
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/v1/secured/dependant/transaction-history'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['code'] == 200 && data['transactions'] != null) {
        setState(() {
          transactions = data['transactions'];
          isLoading = false;
        });
      } else {
        setState(() {
          transactions = [];
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      // Optionally show an error message or handle error specific cases
    }
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return Card( // Wrap with Card for better UI
      child: ListTile(
        leading: Icon(Icons.payment, color: Theme.of(context).primaryColor),
        title: Text(transaction['transaction_type']['name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text('Completed on: ${transaction['completed_at']}', style: TextStyle(color: Colors.grey.shade600)),
        trailing: Text('RM${transaction['amount']}', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transaction History"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchTransactionHistory,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : transactions.isEmpty
          ? Center(child: Text("No transactions found", style: TextStyle(fontSize: 16)))
          : ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return _buildTransactionItem(transactions[index]);
        },
      ),
    );
  }
}

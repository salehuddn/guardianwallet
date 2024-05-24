import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tokenmanager.dart';
import 'constants.dart';
import 'bottomappbar.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final token = await SecureSessionManager.getToken();
    final response = await http.get(
      Uri.parse('$BASE_API_URL/secured/guardian/transaction-history'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        transactions = data['transactions'];
      });
    } else {
      // Handle errors
      print('Error fetching transactions: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          var transaction = transactions[index];
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
        },
      ),
      bottomNavigationBar: const CustomBottomAppBar(currentIndex: 1),
    );
  }
}

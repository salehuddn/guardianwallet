import 'package:flutter/material.dart';
import 'package:guardianwallet/constants.dart';
import 'package:intl/intl.dart';
import 'guardianmenu.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tokenmanager.dart'; // Assuming this manages the token for API calls

class GuardianReceiptPage extends StatefulWidget {
  final Map<String, dynamic> transactionData;

  const GuardianReceiptPage({super.key, required this.transactionData});

  @override
  _GuardianReceiptPageState createState() => _GuardianReceiptPageState();
}

class _GuardianReceiptPageState extends State<GuardianReceiptPage> {
  late List<Map<String, dynamic>> _latestTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchLatestTransactions();
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

  @override
  Widget build(BuildContext context) {
    // Ensure 'completed_at' is present and correctly formatted
    DateTime completedAt;
    String formattedCompletedAt = 'Invalid date';
    if (widget.transactionData['completed_at'] != null) {
      try {
        // Parse the UTC time
        completedAt = DateTime.parse(widget.transactionData['completed_at']).toUtc();
        // Convert to Kuala Lumpur time
        completedAt = completedAt.add(const Duration(hours: 8)); // Kuala Lumpur is UTC+8
        // Format the date
        formattedCompletedAt = DateFormat('dd/MM/yy HH:mm').format(completedAt);
      } catch (e) {
        formattedCompletedAt = 'Invalid date';
      }
    }

    // Format amount to ensure it's shown with two decimal places
    String formattedAmount = 'N/A';
    if (widget.transactionData['amount'] != null) {
      double amount = double.tryParse(widget.transactionData['amount'].toString()) ?? 0;
      formattedAmount = 'RM${amount.toStringAsFixed(2)}';
    }

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 80,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Payment Success!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      formattedAmount,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Divider(),
                    SizedBox(height: 16),
                    Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Transaction ID'),
                        Text('${widget.transactionData['reference'] ?? 'N/A'}'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status'),
                        Row(
                          children: [
                            Text('${widget.transactionData['status'] ?? 'N/A'}'),
                            SizedBox(width: 4),
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Completed At'),
                        Text(formattedCompletedAt),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Description'),
                        Text('${widget.transactionData['narration'] ?? 'N/A'}'),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const GuardianMenuPage()),
                        );
                      },
                      child: const Text('DONE'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

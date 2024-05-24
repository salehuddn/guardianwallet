import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'guardianmenu.dart';

class GuardianReceiptPage extends StatelessWidget {
  final Map<String, dynamic> transactionData;

  const GuardianReceiptPage({super.key, required this.transactionData});

  @override
  Widget build(BuildContext context) {
    // Ensure 'completed_at' is present and correctly formatted
    DateTime completedAt;
    String formattedCompletedAt = 'Invalid date';
    if (transactionData['completed_at'] != null) {
      try {
        completedAt = DateTime.parse(transactionData['completed_at']);
        formattedCompletedAt = DateFormat('dd/MM/yy HH:mm').format(completedAt);
      } catch (e) {
        formattedCompletedAt = 'Invalid date';
      }
    }

    // Format amount to ensure it's shown with two decimal places
    String formattedAmount = 'N/A';
    if (transactionData['amount'] != null) {
      double amount = double.tryParse(transactionData['amount'].toString()) ?? 0;
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
                        Text('${transactionData['reference'] ?? 'N/A'}'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status'),
                        Row(
                          children: [
                            Text('${transactionData['status'] ?? 'N/A'}'),
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
                        Text('${transactionData['narration'] ?? 'N/A'}'),
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

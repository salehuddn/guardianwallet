import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'guardianmenu.dart';

class GuardianReceiptPage extends StatelessWidget {
  final Map<String, dynamic> transactionData;

  GuardianReceiptPage({Key? key, required this.transactionData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure 'completed_at' is present and correctly formatted
    String completedAt = 'N/A';
    if (transactionData['completed_at'] != null) {
      try {
        completedAt = DateFormat('d MMMM y H:mm').format(DateTime.parse(transactionData['completed_at']));
      } catch (e) {
        completedAt = 'Invalid date';
      }
    }

    // Format amount to ensure it's shown with two decimal places
    String formattedAmount = 'N/A';
    if (transactionData['amount'] != null) {
      double amount = double.tryParse(transactionData['amount'].toString()) ?? 0;
      formattedAmount = 'RM${amount.toStringAsFixed(2)}';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Receipt'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reference: ${transactionData['reference'] ?? 'N/A'}'),
            Text('Amount: $formattedAmount'),
            Text('Completed at: $completedAt'),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Direct navigation to the GuardianMenu widget using Navigator.pushReplacement
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => GuardianMenuPage())
                  );
                },
                child: Text('DONE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

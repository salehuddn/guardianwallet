import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'dependentmenu.dart'; // Import the dependent menu page

class DependentReceiptPage extends StatelessWidget {
  final Map<String, dynamic> transactionData;

  const DependentReceiptPage({super.key, required this.transactionData});

  @override
  Widget build(BuildContext context) {
    // Parse the completed_at date string and convert to Kuala Lumpur time
    DateTime completedAt = DateTime.parse(transactionData['transaction']['completed_at']).toUtc();
    completedAt = completedAt.add(Duration(hours: 8)); // Kuala Lumpur is UTC+8
    String formattedCompletedAt = DateFormat('dd/MM/yy HH:mm').format(completedAt);

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Center(
        child: SingleChildScrollView(
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
                        'RM ${transactionData['transaction']['amount']}',
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
                          Expanded(
                            child: Text(
                              '${transactionData['transaction']['reference']}',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Status'),
                          Row(
                            children: [
                              Text('${transactionData['transaction']['status']}'),
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
                          Expanded(
                            child: Text(
                              formattedCompletedAt,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Description'),
                          Expanded(
                            child: Text(
                              '${transactionData['transaction']['narration']}',
                              textAlign: TextAlign.right,
                            ),
                          ),
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
                            MaterialPageRoute(builder: (_) => const DependentMenuPage()),
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
      ),
    );
  }
}

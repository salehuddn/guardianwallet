import 'package:flutter/material.dart';
import 'dependentmenu.dart'; // Import the dependent menu page

class DependentReceiptPage extends StatelessWidget {
  final Map<String, dynamic> transactionData;

  const DependentReceiptPage({super.key, required this.transactionData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transaction Receipt")),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          ListTile(
            title: const Text("Transaction ID"),
            subtitle: Text("${transactionData['transaction']['id']}"),
          ),
          ListTile(
            title: const Text("Amount"),
            subtitle: Text("RM ${transactionData['transaction']['amount']}"),
          ),
          ListTile(
            title: const Text("Status"),
            subtitle: Text("${transactionData['transaction']['status']}"),
          ),
          ListTile(
            title: const Text("Completed At"),
            subtitle: Text("${transactionData['transaction']['completed_at']}"),
          ),
          ListTile(
            title: const Text("Narration"),
            subtitle: Text("${transactionData['transaction']['narration']}"),
          ),
          const SizedBox(height: 20),
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
    );
  }
}

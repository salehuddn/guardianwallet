import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dependentreceipt.dart'; // Import the receipt page
import 'constants.dart';

class DependentPaymentPage extends StatefulWidget {
  @override
  _DependentPaymentPageState createState() => _DependentPaymentPageState();
}

class _DependentPaymentPageState extends State<DependentPaymentPage> {
  // Variable to store merchant name
  String merchantName = '';

  // Method to scan QR code (this is a placeholder for actual QR scanning functionality)
  Future<void> scanQR() async {
    // Assume the QR scan result is stored in a variable called 'qrResult'
    String qrResult = "sampleQRCode"; // This should come from the actual QR scanner

    // POST request to your endpoint
    final response = await http.post(
      Uri.parse('$BASE_API_URL/secured/dependant/scan-qr'),
      body: jsonEncode({'qr_code': qrResult}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData['code'] == "200") {
        setState(() {
          merchantName = responseData['merchant']['name'];
        });

        // Prompt to continue to payment input
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Merchant Scanned'),
              content: Text('You have scanned $merchantName. Continue to payment?'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss dialog
                    _redirectToPaymentInput(); // Function to redirect to payment input page
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      // Handle errors or unsuccessful scans
      print('Failed to scan');
    }
  }

  // Redirect to a page to input payment amount
  void _redirectToPaymentInput() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PaymentInputPage(merchantName: merchantName)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Merchant QR'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: scanQR,
              child: Text('Scan QR'),
            ),
            Text(merchantName.isNotEmpty ? 'Merchant: $merchantName' : 'No merchant scanned'),
          ],
        ),
      ),
    );
  }
}

// Assume there's a PaymentInputPage where the amount is entered
class PaymentInputPage extends StatelessWidget {
  final String merchantName;
  PaymentInputPage({required this.merchantName});

  @override
  Widget build(BuildContext context) {
    TextEditingController _amountController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Amount'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Amount',
            ),
            keyboardType: TextInputType.number,
          ),
          ElevatedButton(
            child: Text('Transfer Now'),
            onPressed: () {
              // Assuming the transfer is always successful for this example
              Navigator.push(context, MaterialPageRoute(builder: (_) => DependentReceiptPage()));
            },
          ),
        ],
      ),
    );
  }
}

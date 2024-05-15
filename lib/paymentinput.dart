import 'package:flutter/material.dart';
import 'package:guardianwallet/tokenmanager.dart';
import 'dependentreceipt.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentInputPage extends StatelessWidget {
  final String merchantId;

  const PaymentInputPage({super.key, required this.merchantId});

  @override
  Widget build(BuildContext context) {
    TextEditingController amountController = TextEditingController();

    Future<void> makePayment() async {
      final token = await SecureSessionManager.getToken();

      final response = await http.post(
        Uri.parse('$BASE_API_URL/secured/dependant/transfer-fund'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'merchant_id': merchantId,
          'amount': amountController.text,
        }),
      );

      print("HTTP response code: ${response.statusCode}");
      print("HTTP response body: ${response.body}");

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        // Navigate to receipt page with transaction details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DependentReceiptPage(transactionData: responseData),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment failed')));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Amount'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => amountController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: makePayment,
              child: const Text('Transfer Now'),
            ),
          ],
        ),
      ),
    );
  }
}

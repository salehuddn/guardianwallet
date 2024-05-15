import 'package:flutter/material.dart';
import 'package:guardianwallet/tokenmanager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'guardianreceipt.dart';
import 'constants.dart';

class TopUpWalletPage extends StatefulWidget {
  const TopUpWalletPage({super.key});

  @override
  _TopUpWalletPageState createState() => _TopUpWalletPageState();
  static const String successUrl = '$BASE_API_URL/public/success?transaction_id=';
  static const String cancelUrl = '$BASE_API_URL/public/cancel?transaction_id=';
}

class _TopUpWalletPageState extends State<TopUpWalletPage> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _startTopUp() async {
    final token = await SecureSessionManager.getToken();
    final response = await http.post(
      Uri.parse('$BASE_API_URL/secured/guardian/topup-wallet'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'amount': _amountController.text,
      }),
    );

    if (response.statusCode == 200) {
      final checkoutUrl = json.decode(response.body)['checkoutUrl'];
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Top Up')),
            body: WebView(
              initialUrl: checkoutUrl,
              javascriptMode: JavascriptMode.unrestricted,
              navigationDelegate: (NavigationRequest request) {
                var url = Uri.parse(request.url);
                if (url.toString().startsWith(TopUpWalletPage.successUrl)) {
                  _handlePaymentSuccess(url.queryParameters['transaction_id']!);
                  return NavigationDecision.prevent;
                }
                if (url.toString().startsWith(TopUpWalletPage.cancelUrl)) {
                  _handlePaymentCancel(url.queryParameters['transaction_id']!);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to initiate top-up')),
      );
    }
  }

  void _handlePaymentSuccess(String transactionId) async {
    final token = await SecureSessionManager.getToken();
    final response = await http.get(
      Uri.parse('${TopUpWalletPage.successUrl}$transactionId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final transactionData = json.decode(response.body)['transaction'];
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GuardianReceiptPage(transactionData: transactionData),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to retrieve transaction details')),
      );
    }
  }

  void _handlePaymentCancel(String transactionId) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment cancelled')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Up Wallet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount to Top Up',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startTopUp,
              child: const Text('Top Up Now'),
            ),
          ],
        ),
      ),
    );
  }
}

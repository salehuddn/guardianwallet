import 'package:flutter/material.dart';
import 'package:guardianwallet/paymentinput.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// Import the receipt page
import 'constants.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'tokenmanager.dart';  // Use mobile_scanner instead of qrscan

class DependentPaymentPage extends StatefulWidget {
  const DependentPaymentPage({super.key});

  @override
  _DependentPaymentPageState createState() => _DependentPaymentPageState();
}

class _DependentPaymentPageState extends State<DependentPaymentPage> {
  String merchantId = '';

  @override
  void initState() {
    super.initState();
    // Remove WidgetsBinding if not needed
  }

  @override
  void dispose() {
    super.dispose();
  }

  // void _handleQRScan(String qrResult) async {
  //   print("QR Result: $qrResult");
  //   try {
  //     final token = await SecureSessionManager.getToken();
  //     var url = Uri.parse('$BASE_API_URL/secured/dependant/scan-qr');
  //     var response = await http.post(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json'
  //       },
  //       body: jsonEncode({'qr_content': qrResult}),
  //     );
  //
  //     print("HTTP response code: ${response.statusCode}");
  //     print("HTTP response body: ${response.body}");
  //
  //     // Follow redirects manually if the server does not handle them.
  //     while (response.statusCode == 302) {
  //       var location = response.headers['location'];
  //       if (location != null) {
  //         url = Uri.parse(location);
  //         response = await http.get(url);
  //         print("Redirected to: $location with status code: ${response.statusCode}");
  //       } else {
  //         // Break the loop if no location is provided (unlikely to happen)
  //         break;
  //       }
  //     }
  //
  //     if (response.statusCode == 200) {
  //       var responseData = json.decode(response.body);
  //       if (responseData.containsKey('merchant')) {
  //         setState(() {
  //           merchantId = responseData['merchant']['id'];
  //         });
  //         Navigator.of(context).push(MaterialPageRoute(builder: (_) => PaymentInputPage(merchantId: merchantId)));
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No valid merchant data found')));
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to scan')));
  //     }
  //   } catch (e) {
  //     print("Error occurred while sending request: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error occurred while sending request: $e')));
  //   }
  // }

  void _handleQRScan(String qrResult) async {
    print("QR Result: $qrResult");
    try {
      final token = await SecureSessionManager.getToken();
      var url = Uri.parse('$BASE_API_URL/secured/dependant/scan-qr');
      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'qr_content': qrResult}),
      );

      print("HTTP response code: ${response.statusCode}");
      print("HTTP response body: ${response.body}");

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData.containsKey('merchant')) {
          var merchant = responseData['merchant'];
          if (merchant is Map<String, dynamic> && merchant.containsKey('id')) {
            setState(() {
              merchantId = merchant['id'].toString();  // Ensure merchantId is a string
            });
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => PaymentInputPage(merchantId: merchantId)));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No valid merchant data found')));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No valid merchant data found')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to scan')));
      }
    } catch (e) {
      print("Error occurred while sending request: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error occurred while sending request: $e')));
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Merchant QR'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: MobileScanner(
                onDetect: (capture) {
                  final Barcode? barcode = capture.barcodes.firstOrNull;
                  final String? code = barcode?.rawValue;
                  if (code != null) {
                    _handleQRScan(code);
                  }
                }

            ),
          ),
          Text(merchantId.isNotEmpty ? 'Merchant: $merchantId' : 'No merchant scanned'),
        ],
      ),
    );
  }
}
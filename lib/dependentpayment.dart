import 'package:flutter/material.dart';
import 'package:guardianwallet/paymentinput.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'constants.dart';
import 'tokenmanager.dart';

class DependentPaymentPage extends StatefulWidget {
  const DependentPaymentPage({super.key});

  @override
  _DependentPaymentPageState createState() => _DependentPaymentPageState();
}

class _DependentPaymentPageState extends State<DependentPaymentPage> {
  String merchantId = '';
  late MobileScannerController _cameraController;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

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
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: (capture) {
              final Barcode? barcode = capture.barcodes.firstOrNull;
              final String? code = barcode?.rawValue;
              if (code != null) {
                _handleQRScan(code);
              }
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 40),
              padding: const EdgeInsets.all(10),
              color: Colors.black.withOpacity(0.5),
              child: const Text(
                'Point the camera at the QR code',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              padding: const EdgeInsets.all(16.0),
              child: Text(
                merchantId.isNotEmpty ? 'Merchant: $merchantId' : 'No merchant scanned',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Container(
          //     margin: const EdgeInsets.only(bottom: 20),
          //     child: ElevatedButton(
          //       onPressed: () {
          //         // You can add additional functionality here (e.g., a button to manually enter the code)
          //       },
          //       child: const Text('Enter Code Manually'),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

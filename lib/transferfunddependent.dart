import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'guardianreceipt.dart';
import 'tokenmanager.dart';  // Assuming this handles your token storage
import 'constants.dart';

class TransferFundDependentPage extends StatefulWidget {
  const TransferFundDependentPage({super.key});

  @override
  _TransferFundDependentPageState createState() => _TransferFundDependentPageState();
}

class _TransferFundDependentPageState extends State<TransferFundDependentPage> {
  final _amountController = TextEditingController();
  List<dynamic> dependents = [];
  String? selectedDependent;
  String amount = '';

  @override
  void initState() {
    super.initState();
    fetchDependents();
  }

  Future<void> fetchDependents() async {
    final token = await SecureSessionManager.getToken();
    final response = await http.get(
      Uri.parse('$BASE_API_URL/secured/guardian/dependants'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        dependents = json.decode(response.body)['dependant'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load dependents')),
      );
    }
  }

  void _handleTransfer() async {
    final token = await SecureSessionManager.getToken();
    final response = await http.post(
      Uri.parse('$BASE_API_URL/secured/guardian/transfer-fund'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'dependant_id': selectedDependent,
        'amount': amount,
      }),
    );

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      if (responseBody.containsKey('transaction') && responseBody['transaction'] != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => GuardianReceiptPage(transactionData: responseBody['transaction']),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction data is missing or invalid')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to transfer funds: ${response.body}')),
      );
    }
  }


  void _onNumberPadPress(String input) {
    setState(() {
      if (input == '<') {
        if (amount.isNotEmpty) {
          amount = amount.substring(0, amount.length - 1);
        }
      } else {
        amount += input;
      }
      _amountController.text = amount; // Update the controller with the new amount
    });
  }

  Widget _buildNumberPad() {
    List<String> numbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '<', '0', '.'];
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 2,
      padding: const EdgeInsets.all(8),
      children: numbers.map((number) {
        return TextButton(
          onPressed: () => _onNumberPadPress(number),
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey[200],
            shape: const CircleBorder(),
          ),
          child: Text(number, style: const TextStyle(fontSize: 24, color: Colors.black)),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Fund to Dependent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SecureSessionManager.deleteToken();
              Navigator.of(context).pushReplacementNamed('/login');  // Assuming '/login' is the route for login page
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedDependent,
              hint: const Text('Select Dependent'),
              items: dependents.map<DropdownMenuItem<String>>((dynamic value) {
                return DropdownMenuItem<String>(
                  value: value['id'].toString(),
                  child: Text(value['name']),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDependent = newValue;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                ),
                readOnly: true,
              ),
            ),
            _buildNumberPad(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleTransfer,
              child: const Text('Transfer Now'),
            ),
          ],
        ),
      ),
    );
  }
}

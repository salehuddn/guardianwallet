import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DependentReceiptPage extends StatefulWidget {
  @override
  _DependentReceiptPageState createState() => _DependentReceiptPageState();
}

class _DependentReceiptPageState extends State<DependentReceiptPage> {
  Map<String, dynamic>? lastTransaction;

  @override
  void initState() {
    super.initState();
    _fetchLastTransaction();
  }

  Future<void> _fetchLastTransaction() async {
    var response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/v1/secured/dependant/transaction-history')
    );
    var data = jsonDecode(response.body);
    if (data['code'] == 200 && data['transactions'].isNotEmpty) {
      setState(() {
        lastTransaction = data['transactions'].first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Transaction Receipt")),
      body: lastTransaction == null ? Center(child: CircularProgressIndicator()) : ListView(
        padding: EdgeInsets.all(20.0),
        children: <Widget>[
          ListTile(
            title: Text("Transaction ID"),
            subtitle: Text("${lastTransaction!['id']}"),
          ),
          ListTile(
            title: Text("Amount"),
            subtitle: Text("RM ${lastTransaction!['amount']}"),
          ),
          ListTile(
            title: Text("Status"),
            subtitle: Text("${lastTransaction!['status']}"),
          ),
          ListTile(
            title: Text("Completed At"),
            subtitle: Text("${lastTransaction!['completed_at']}"),
          ),
          ListTile(
            title: Text("Narration"),
            subtitle: Text("${lastTransaction!['narration']}"),
          ),
        ],
      ),
    );
  }
}

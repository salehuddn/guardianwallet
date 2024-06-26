import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tokenmanager.dart';
import 'constants.dart';
import 'bottomappbar.dart';

class ManageDependentPage extends StatefulWidget {
  const ManageDependentPage({super.key});

  @override
  _ManageDependentPageState createState() => _ManageDependentPageState();
}

class _ManageDependentPageState extends State<ManageDependentPage> {
  List<dynamic> dependents = [];
  dynamic selectedDependent;
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    _fetchDependents();
  }

  Future<void> _fetchDependents() async {
    final token = await SecureSessionManager.getToken();
    final response = await http.get(
      Uri.parse('$BASE_API_URL/secured/guardian/dependants'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        dependents = data['dependant'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load dependents')),
      );
    }
  }

  void _showEditDialog(String key, String title, String currentValue) {
    if (key == 'dob') {
      _selectDate(context, currentValue);
    } else {
      TextEditingController controller = TextEditingController(text: currentValue);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Edit $title'),
            content: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Enter $title',
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _updateDependent(key, controller.text);
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _selectDate(BuildContext context, String currentValue) async {
    DateTime initialDate = DateTime.tryParse(currentValue) ?? DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = "${pickedDate.toLocal()}".split(' ')[0];
      _updateDependent('dob', formattedDate);
    }
  }

  Future<void> _updateDependent(String key, String value) async {
    final token = await SecureSessionManager.getToken();
    final response = await http.post(
      Uri.parse('$BASE_API_URL/secured/guardian/update-dependant/${selectedDependent['id']}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'dependant_id': selectedDependent['id'],
        key: value,
      }),
    );

    print('Response Body: ${response.body}');


    if (response.statusCode == 200) {
      setState(() {
        selectedDependent[key] = value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dependent updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update dependent: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Dependents'),
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            DropdownButton<dynamic>(
              value: selectedDependent,
              items: dependents.map<DropdownMenuItem<dynamic>>((dep) {
                return DropdownMenuItem<dynamic>(
                  value: dep,
                  child: Text(dep['name']),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedDependent = newValue;
                });
              },
              hint: const Text('Select a dependent'),
            ),
            selectedDependent != null ? _buildDependentDetails() : Container(),
            selectedDependent != null ? _buildTransactionHistory() : Container(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomAppBar(currentIndex: 2),
    );
  }

  Widget _buildDependentDetails() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
            2: FixedColumnWidth(48.0),
          },
          children: [
            _buildTableRow('Name', selectedDependent['name'], 'name', true),
            _buildTableRow('Email', selectedDependent['email'], 'email', true),
            _buildTableRow('Date of Birth', selectedDependent['dob'].substring(0, 10), 'dob', true),
            _buildTableRow('Spending Limit (RM)', '${selectedDependent['spending_limit'] ?? '0.00'}', 'spending_limit', true),
            _buildTableRow('Phone', selectedDependent['phone'] ?? 'N/A', 'phone', true),
            _buildTableRow('Wallet', 'RM${selectedDependent['wallet'] ?? '0.00'}', 'wallet', false),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String title, String value, String key, bool isEditable) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(value),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: isEditable ? IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(key, title, value),
          ) : Container(),
        ),
      ],
    );
  }

  Widget _buildTransactionHistory() {
    final transactionHistory = selectedDependent['transaction_history'] as List<dynamic>;
    if (transactionHistory.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No transaction history available.'),
      );
    }
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Transaction History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8.0),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactionHistory.length,
              itemBuilder: (context, index) {
                final transaction = transactionHistory[index];
                return ListTile(
                  leading: Icon(Icons.monetization_on, color: Colors.green[700]),
                  title: Text('${transaction['transaction_type']['name']} - RM${transaction['amount']}'),
                  subtitle: Text(transaction['completed_at']),
                  trailing: Text(transaction['status']),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

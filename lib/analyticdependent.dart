import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'tokenmanager.dart';
import 'constants.dart';
import 'dependentprofile.dart';
import 'dependentpayment.dart';
import 'dependentmenu.dart';

class AnalyticDependentPage extends StatefulWidget {
  const AnalyticDependentPage({super.key});

  @override
  _AnalyticDependentPageState createState() => _AnalyticDependentPageState();
}

class _AnalyticDependentPageState extends State<AnalyticDependentPage> {
  bool isLoading = true;
  dynamic analyticData;

  @override
  void initState() {
    super.initState();
    _fetchAnalyticData();
  }

  Future<void> _fetchAnalyticData() async {
    final token = await SecureSessionManager.getToken();
    final dependentId = await _fetchDependentId(token!);

    final response = await http.get(
      Uri.parse('$BASE_API_URL/secured/analytic/budget/$dependentId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        analyticData = data['data'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load analytic data')),
      );
    }
  }

  Future<int> _fetchDependentId(String token) async {
    final response = await http.get(
      Uri.parse('$BASE_API_URL/secured/dependant/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['user']['id']; // Assuming 'id' is the dependent ID
    } else {
      throw Exception('Failed to load dependent ID');
    }
  }

  void _selectPage(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DependentMenuPage(currentIndex: index)));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DependentProfilePage()));
        break;
      case 3:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DependentPaymentPage()));
        break;
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildIconButton(Icons.home, 0),
          const Spacer(),
          _buildIconButton(Icons.qr_code_scanner, 3, isFloating: true),
          const Spacer(),
          _buildIconButton(Icons.account_circle, 1),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, int index, {bool isFloating = false}) {
    return IconButton(
      icon: Icon(icon),
      iconSize: isFloating ? 30.0 : 24.0,
      onPressed: () => _selectPage(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dependent Analytics'),
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: analyticData != null
            ? _buildAnalyticDetails()
            : const Center(child: Text('No data available')),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAnalyticDetails() {
    final income = double.parse(analyticData['income'] ?? '0');
    final percentages = analyticData['percentages'];
    final needs = income * (percentages['needs'] ?? 0);
    final wants = income * (percentages['wants'] ?? 0);
    final savings = income * (percentages['savings'] ?? 0);
    final allowanceBalance = income - (needs + wants + savings);

    final dataMap = {
      "Needs": needs,
      "Wants": wants,
      "Savings": savings,
      "Allowance Balance": allowanceBalance,
    };

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _buildPieChartSections(dataMap),
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.all(16.0),
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnalyticRow('Allowance', 'RM${analyticData['income'] ?? '0'}'),
                _buildAnalyticRow('Needs', '${(percentages['needs'] * 100).toStringAsFixed(1)}% (RM${dataMap['Needs']!.toStringAsFixed(2)})'),
                _buildAnalyticRow('Wants', '${(percentages['wants'] * 100).toStringAsFixed(1)}% (RM${dataMap['Wants']!.toStringAsFixed(2)})'),
                _buildAnalyticRow('Savings', '${(percentages['savings'] * 100).toStringAsFixed(1)}% (RM${dataMap['Savings']!.toStringAsFixed(2)})'),
                _buildAnalyticRow('Allowance Balance', '${(allowanceBalance / income * 100).toStringAsFixed(1)}% (RM${dataMap['Allowance Balance']!.toStringAsFixed(2)})'),
                _buildAnalyticRow('Needs Status', analyticData['analysis']['needs'] ?? 'N/A'),
                _buildAnalyticRow('Wants Status', analyticData['analysis']['wants'] ?? 'N/A'),
                _buildAnalyticRow('Savings Status', analyticData['analysis']['savings'] ?? 'N/A'),
                const SizedBox(height: 8.0),
                const Text('Recommendations', style: TextStyle(fontWeight: FontWeight.bold)),
                for (var recommendation in (analyticData['recommendations'] ?? []))
                  Text('- $recommendation'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> dataMap) {
    final List<Color> colors = [Colors.blue, Colors.red, Colors.green, Colors.orange];
    int index = 0;
    return dataMap.entries.map((entry) {
      final double value = entry.value;
      final String label = entry.key;
      final Color color = colors[index % colors.length];
      index++;
      return PieChartSectionData(
        color: color,
        value: value,
        title: '${(value / dataMap.values.reduce((a, b) => a + b) * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildAnalyticRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

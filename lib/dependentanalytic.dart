import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'tokenmanager.dart';
import 'constants.dart';
import 'bottomappbar.dart';

class DependentAnalyticPage extends StatefulWidget {
  const DependentAnalyticPage({super.key});

  @override
  _DependentAnalyticPageState createState() => _DependentAnalyticPageState();
}

class _DependentAnalyticPageState extends State<DependentAnalyticPage> {
  List<dynamic> dependents = [];
  dynamic selectedDependent;
  bool isLoading = true;
  dynamic analyticData;

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

  Future<void> _fetchAnalyticData(int dependentId) async {
    final token = await SecureSessionManager.getToken();
    final response = await http.get(
      Uri.parse('$BASE_API_URL/secured/analytic/budget/$dependentId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        analyticData = data;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load analytic data')),
      );
    }
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
                  analyticData = null;
                });
                _fetchAnalyticData(selectedDependent['id']);
              },
              hint: const Text('Select a dependent'),
            ),
            selectedDependent != null
                ? analyticData != null
                ? _buildAnalyticDetails()
                : const Center(child: CircularProgressIndicator())
                : Container(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomAppBar(currentIndex: 2),
    );
  }

  Widget _buildAnalyticDetails() {
    final income = double.parse(analyticData['income']);
    final spending = analyticData['spending'];
    final dataMap = {
      "Needs": (income * spending['needs'] / 100),
      "Wants": (income * spending['wants'] / 100),
      "Savings": (income * spending['savings'] / 100),
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
                _buildAnalyticRow('Income', 'RM${analyticData['income']}'),
                _buildAnalyticRow('Needs', '${spending['needs']}% (RM${dataMap['Needs']})'),
                _buildAnalyticRow('Wants', '${spending['wants']}% (RM${dataMap['Wants']})'),
                _buildAnalyticRow('Savings', '${spending['savings']}% (RM${dataMap['Savings']})'),
                _buildAnalyticRow('Needs Status', analyticData['analysis']['needs']),
                _buildAnalyticRow('Wants Status', analyticData['analysis']['wants']),
                _buildAnalyticRow('Savings Status', analyticData['analysis']['savings']),
                const SizedBox(height: 8.0),
                Text('Recommendations', style: const TextStyle(fontWeight: FontWeight.bold)),
                for (var recommendation in analyticData['recommendations'])
                  Text('- $recommendation'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> dataMap) {
    final List<Color> colors = [Colors.blue, Colors.red, Colors.green];
    int index = 0;
    return dataMap.entries.map((entry) {
      final double value = entry.value;
      final String label = entry.key;
      final Color color = colors[index % colors.length];
      index++;
      return PieChartSectionData(
        color: color,
        value: value,
        title: '${value.toStringAsFixed(1)}%',
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

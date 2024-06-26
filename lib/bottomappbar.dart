import 'package:flutter/material.dart';
import 'guardianmenu.dart';
import 'managedependent.dart';
import 'topupwallet.dart';

class CustomBottomAppBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomAppBar({Key? key, required this.currentIndex}) : super(key: key);

  void _selectPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => GuardianMenuPage(currentIndex: index)));
        break;
      case 1:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TopUpWalletPage()));
        break;
      case 2:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ManageDependentPage()));
        break;
    }
  }

  Widget _buildIconButton(BuildContext context, IconData icon, int index, String label) {
    return GestureDetector(
      onTap: () => _selectPage(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: currentIndex == index ? Colors.blue : Colors.grey,
          ),
          const SizedBox(height: 2),  // Add spacing between icon and text
          Text(
            label,
            style: TextStyle(
              color: currentIndex == index ? Colors.blue : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildIconButton(context, Icons.home, 0, 'Home'),
          _buildIconButton(context, Icons.attach_money, 1, 'Top Up Wallet'),
          _buildIconButton(context, Icons.transfer_within_a_station, 2, 'Dependent'),
        ],
      ),
    );
  }
}

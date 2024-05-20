import 'package:flutter/material.dart';
import 'guardianmenu.dart';
import 'transactionhistory.dart';
import 'managedependent.dart';
import 'guardianprofilepage.dart';
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
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TransactionHistoryPage()));
        break;
      case 2:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TopUpWalletPage()));
        break;
      case 3:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ManageDependentPage()));
        break;
      case 4:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const GuardianProfilePage()));
        break;
    }
  }

  Widget _buildIconButton(BuildContext context, IconData icon, int index) {
    return IconButton(
      icon: Icon(icon),
      color: currentIndex == index ? Colors.blue : Colors.grey,
      onPressed: () => _selectPage(context, index),
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
          _buildIconButton(context, Icons.home, 0),
          _buildIconButton(context, Icons.history, 1),
          _buildIconButton(context, Icons.attach_money, 2),
          _buildIconButton(context, Icons.transfer_within_a_station, 3),
          _buildIconButton(context, Icons.supervised_user_circle, 4),
        ],
      ),
    );
  }
}

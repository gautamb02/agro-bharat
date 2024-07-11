import 'package:agro_bharat/components/bottombar.dart';
import 'package:agro_bharat/screens/add_cow.dart';
import 'package:agro_bharat/screens/dashboard.dart';
import 'package:agro_bharat/screens/locate_cow.dart';
import 'package:agro_bharat/screens/profile.dart';
import 'package:agro_bharat/screens/settings.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentTab = 0;
  final List<Widget> screens = [
    Dashboard(),
    LocateCow(),
    AddCow(),
    Settings(),
    FarmerProfile()
  ];

  final PageStorageBucket pageStorageBucket = PageStorageBucket();
  Widget currentScreen = Dashboard();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      currentScreen = screens[index];
      // Here you would also update the currentScreen based on the index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: pageStorageBucket, child: currentScreen),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

}

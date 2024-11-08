import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../screens/home_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/class_list_screen.dart';
import '../screens/booked_classes_screen.dart';
import '../screens/settings_screen.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  Widget _buildNavigator(Widget screen, int index) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) => MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    } else {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildNavigator(HomeScreen(), 0),
          _buildNavigator(CalendarScreen(), 1),
          _buildNavigator(ClassListScreen(), 2),
          _buildNavigator(BookedClassesScreen(), 3),
          _buildNavigator(SettingsScreen(), 4),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        backgroundColor: AppColors.buttonColor,
        selectedItemColor: AppColors.backgroundColor,
        unselectedItemColor: AppColors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Booked',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
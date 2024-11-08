import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yoga_client/views/screens/account_profile_screen.dart';
import '../../themes/app_colors.dart';
import 'cart_screen.dart';
import 'search_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontFamily: 'AfacAdflux'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildAccountCard(context),
          _buildLogoutCard(context),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: const Icon(
            Icons.logout,
            color: Colors.black,
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 18,
              fontFamily: 'AfacAdflux',
            ),
          ),
          onTap: () async {
            await _showLogoutConfirmation(context);
          },
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: const Icon(
            Icons.account_circle,
            color: Colors.black,
          ),
          title: const Text(
            'Account & Profile',
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 18,
              fontFamily: 'AfacAdflux',
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AccountProfileScreen()),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout', style: TextStyle(fontFamily: 'AfacAdflux', color: AppColors.backgroundColor, fontSize: 18)),
        content: const Text('Are you sure you want to log out?' , style: TextStyle(fontFamily: 'AfacAdflux', color: AppColors.accentColor, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'AfacAdflux', color: AppColors.accentColor, fontSize: 18),),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout',  style: TextStyle(fontFamily: 'AfacAdflux', color: AppColors.backgroundColor, fontSize: 18)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _handleLogout(context);
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await _auth.signOut();

      // Đợi một chút trước khi điều hướng
      await Future.delayed(const Duration(milliseconds: 500));

      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }
}

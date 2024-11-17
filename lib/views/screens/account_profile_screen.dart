import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:yoga_client/themes/app_colors.dart';

class AccountProfileScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;
  final DatabaseReference _instructorRef = FirebaseDatabase.instance.ref().child('instructors');

  AccountProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Account & Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'AfacAdflux',
          ),
        ),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Avatar
          const Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://img.icons8.com/?size=100&id=23239&format=png&color=000000'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Name user from Firebase
          _buildProfileField(context, 'Name', _getUserName(), Icons.person, () {

          }),

          // Email
          _buildProfileField(context, 'Email', Text(
            user?.email ?? 'Enter your email',
            style: const TextStyle(
                color: AppColors.white,
                fontFamily: 'AfacAdflux',
              fontSize: 14
            ),
          ), Icons.email, () {

          }),

          const Divider(height: 40, color: Colors.grey),

          ListTile(
            leading: const Icon(Icons.lock, color: Colors.grey),
            title: const Text(
              'Privacy Settings',
              style: TextStyle(fontSize: 18, fontFamily: 'AfacAdflux', color: AppColors.accentColor),
            ),
            subtitle: const Text('Manage privacy for profile and activities', style: TextStyle(color: AppColors.white, fontFamily: 'AfacAdflux',),),
            trailing: const Icon(Icons.chevron_right, color: AppColors.white,),
            onTap: () {

            },
          ),
        ],
      ),
    );
  }

  // Function get name user by email
  Widget _getUserName() {
    return FutureBuilder<String?>(
      future: _fetchUserName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }
        if (snapshot.hasError) {
          return const Text('Error loading name.');
        }

        final name = snapshot.data ?? 'Name not found';
        return Text(name, style: const TextStyle(
          fontSize: 14,
          color: AppColors.white,
          fontFamily: 'AfacAdflux',
        ));
      },
    );
  }

  // Function fetch name of user by email
  Future<String?> _fetchUserName() async {
    if (user?.email == null) return null;

    final snapshot = await _instructorRef.orderByChild('email').equalTo(user!.email!).once();

    if (snapshot.snapshot.value != null) {
      final instructorData = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      return instructorData.values.first['name']; // return name
    }

    return null;
  }

  Widget _buildProfileField(BuildContext context, String title, Widget value, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: AppColors.accentColor,
          fontFamily: 'AfacAdflux',
        ),
      ),
      subtitle: value,
      trailing: const Icon(Icons.chevron_right, color: AppColors.white),
      onTap: onTap,
    );
  }
}
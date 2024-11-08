import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../../views/widgets/bottom_nav_bar.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/leaves.png',
                fit: BoxFit.cover,
                height: 420,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Center(
                        child: Image.asset(
                          'assets/images/icon.png', // Hình logo
                          width: 150,
                          height: 150,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildHeaderText(),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          'Do meditation. Stay focused. Live a healthy life.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontFamily: 'AfacAdflux',
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildInputField(
                        controller: emailController,
                        hintText: 'Email Address',
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        controller: passwordController,
                        hintText: 'Password',
                        icon: Icons.lock,
                        obscureText: true,
                      ),
                      const SizedBox(height: 40),
                      _buildLoginButton(context),
                      const SizedBox(height: 20),
                      _buildRegisterLink(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderText() {
    return const Center(
      child: Text(
        'WELCOME',
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'AfacAdflux',
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white, fontFamily: 'AfacAdflux'),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: const Color(0xFF8D8767)),
        filled: true,
        fillColor: const Color(0xFF253334),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: const Color(0xFF8D8767),
        ),
        onPressed: () => _loginUser(context),
        child: const Text(
          'Login',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontFamily: 'AfacAdflux',
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterScreen()),
          );
        },
        child: const Text(
          "Don't have an account? Sign Up",
          style: TextStyle(
            color: Colors.white70,
            decoration: TextDecoration.underline,
            fontFamily: 'AfacAdflux',
          ),
        ),
      ),
    );
  }

  Future<void> _loginUser(BuildContext context) async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(context, 'Please fill all fields.');
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        _showSnackBar(context, 'Login successful!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavBar()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showSnackBar(context, 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        _showSnackBar(context, 'Incorrect password.');
      } else if (e.code == 'invalid-email') {
        _showSnackBar(context, 'The email address is not valid.');
      } else if (e.code == 'user-disabled') {
        _showSnackBar(context, 'This user account has been disabled.');
      } else {
        _showSnackBar(context, 'Login failed: ${e.message}');
      }
    } catch (e) {
      _showSnackBar(context, 'An unexpected error occurred: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

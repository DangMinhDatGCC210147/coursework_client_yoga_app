import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF253334),
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
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: Image.asset(
                          'assets/images/icon.png',
                          width: 150,
                          height: 150,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildHeaderText(),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          'Create your account to start your journey.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontFamily: 'AfacAdflux',
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildInputField(
                        controller: nameController,
                        hintText: 'Name',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 30),
                      _buildRegisterButton(context),
                      const SizedBox(height: 10),
                      _buildLoginLink(context),
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
        'Create Account',
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'AfacAdflux',
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        },
        child: const Text(
          "Do you have an account? Sign in",
          style: TextStyle(
            color: Colors.white70,
            decoration: TextDecoration.underline,
            fontFamily: 'AfacAdflux',
          ),
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
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
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
        onPressed: () async {
          await registerUser(context);
        },
        child: const Text(
          'Register',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontFamily: 'AfacAdflux',
          ),
        ),
      ),
    );
  }

  Future<void> registerUser(BuildContext context) async {
    final String name = nameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar(context, 'Please fill all fields.');
      return;
    }

    if (!EmailValidator.validate(email)) {
      _showSnackBar(context, 'Invalid email address.');
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        final hashedPassword = sha256.convert(utf8.encode(password)).toString();

        DatabaseReference instructorsRef = FirebaseDatabase.instance.ref(
            'instructors');
        int newId = 1;

        final snapshot = await instructorsRef.get();
        if (snapshot.exists) {
          final instructors = snapshot.children;
          final maxId = instructors
              .map((e) => int.tryParse(e.key ?? '0') ?? 0)
              .reduce((curr, next) => curr > next ? curr : next);
          newId = maxId + 1;
        }

        UserModel newUser = UserModel(
          id: newId.toString(),
          name: name,
          email: email,
          password: hashedPassword,
        );

        await instructorsRef.child(newId.toString()).set(newUser.toJson());

        _showSnackBar(context, 'Registration successful');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(context, 'Registration failed: ${e.message}');
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
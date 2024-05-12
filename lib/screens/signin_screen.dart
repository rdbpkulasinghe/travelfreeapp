import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelfreeapp/accomadation/accomadation_home.dart';
import 'package:travelfreeapp/admin/admin_home.dart';
import 'package:travelfreeapp/guide/guide_home.dart';
import 'package:travelfreeapp/reusable_widget/reusable_widget.dart';
import 'package:travelfreeapp/screens/forgetpassword.dart';
import 'package:travelfreeapp/screens/signup_screen.dart';
import 'package:travelfreeapp/screens/welcomepage.dart';
import 'package:travelfreeapp/utils/colors_utils.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("4169E1"),
              hexStringToColor("05E96B"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).size.height * 0.2,
              20,
              0,
            ),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/logo1.png"),
                const SizedBox(
                  height: 30,
                ),
                _buildTextField("Enter Email", Icons.person_outline, false,
                    _emailTextController),
                const SizedBox(
                  height: 20,
                ),
                _buildTextField("Enter Password", Icons.lock_outline, true,
                    _passwordTextController),
                signInSignUpButton(
                  context,
                  true,
                  () {
                    signInWithUserRole();
                  },
                  textColor: Colors.white,
                ),
                forgotPasswordOption(),
                signUpOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, IconData icon, bool obscureText,
      TextEditingController controller) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget forgotPasswordOption() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ForgetPasswordPage()),
        );
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Forgot Password?",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: Colors.black),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignUpScreen(),
              ),
            );
          },
          child: const Text(
            " Sign Up ",
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void signInWithUserRole() async {
    final String email = _emailTextController.text.trim();
    final String password = _passwordTextController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill in all fields.");
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Retrieve user information including role from Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      Map<String, dynamic>? userData = userDoc.data();

      if (userData != null && userData.containsKey('role')) {
        String userRole = userData['role'];

        // Navigate to the corresponding screen based on user role
        switch (userRole) {
          case 'admin':
            Navigator.push(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
            );
            break;
          case 'hotel':
            Navigator.push(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                  builder: (context) => const AccomadationHomeScreen()),
            );
            break;
          case 'guide':
            Navigator.push(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(builder: (context) => const GuideHomeScreen()),
            );
            break;
          default:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
            break;
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error during sign in: $e");
      String errorMessage = "An error occurred. Invalid username or password.";

      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          errorMessage = "No user found with that email.";
        } else if (e.code == 'wrong-password') {
          errorMessage = "Incorrect password.";
        }
      }

      _showSnackBar(errorMessage); // Display error message
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

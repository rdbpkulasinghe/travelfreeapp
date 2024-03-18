import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelfreeapp/reusable_widget/reusable_widget.dart';
import 'package:travelfreeapp/screens/signin_screen.dart';
import 'package:travelfreeapp/utils/colors_utils.dart';

enum UserRole { guide, traveler }

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();

  UserRole _selectedRole = UserRole.traveler; // Default role

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
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
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                reusableTextField(
                  "Enter UserName",
                  Icons.person_outline,
                  false,
                  _userNameTextController,
                ),
                const SizedBox(height: 20),
                reusableTextField(
                  "Enter Email Id",
                  Icons.person_outline,
                  false,
                  _emailTextController,
                ),
                const SizedBox(height: 20),
                reusableTextField(
                  "Enter Password",
                  Icons.person_outline,
                  false,
                  _passwordTextController,
                ),
                const SizedBox(height: 20),
                // Dropdown for selecting user role
                DropdownButton<UserRole>(
                  value: _selectedRole,
                  onChanged: (UserRole? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                  items: UserRole.values.map<DropdownMenuItem<UserRole>>(
                    (UserRole value) {
                      return DropdownMenuItem<UserRole>(
                        value: value,
                        child: Text(value.toString().split('.').last),
                      );
                    },
                  ).toList(),
                ),
                const SizedBox(height: 20),
                signInSignUpButton(context, false, () {
                  signUpWithUserRole();
                }, textColor: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signUpWithUserRole() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailTextController.text,
              password: _passwordTextController.text);

      // Store additional user information including role in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': _emailTextController.text,
        'username': _userNameTextController.text,
        'role':
            _selectedRole.toString().split('.').last, // Store role as a string
        // Add other user information as needed
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    } catch (e) {
      print("Error during sign up: $e");
      // Handle sign-up errors
    }
  }
}

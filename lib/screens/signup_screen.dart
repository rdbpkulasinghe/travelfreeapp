import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travelfreeapp/reusable_widget/reusable_widget.dart';
import 'package:travelfreeapp/screens/signin_screen.dart';
import 'package:travelfreeapp/utils/colors_utils.dart';

enum UserRole { guide, traveler, hotel, admin }

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _confirmPasswordTextController =
      TextEditingController();
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
                  true,
                  _passwordTextController,
                ),
                const SizedBox(height: 20),
                reusableTextField(
                  "Confirm Password",
                  Icons.person_outline,
                  true,
                  _confirmPasswordTextController,
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
      if (_passwordTextController.text != _confirmPasswordTextController.text) {
        // Passwords do not match, show error message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("Passwords do not match."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
        return;
      }

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
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    } catch (e) {
      String errorMessage = "An error occurred. Please try again later.";

      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          errorMessage = "The account already exists for that email.";
        } else {
          errorMessage = "Something went wrong. Please try again later.";
        }
      }

      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      // ignore: avoid_print
      print("Error during sign up: $e");
    }
  }
}

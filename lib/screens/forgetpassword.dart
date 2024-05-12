import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController _emailTextController = TextEditingController();
  @override
  void dispose() {
    _emailTextController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailTextController.text.trim());
      showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text('Password reset link sent!Check your email'),
            );
          });
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print(e);
      showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 65, 105, 225),
        title: const Text('Forget password'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              'Enter Your Email and we will send you a password reset link',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          ),
          _buildTextField(
              "Enter Email", Icons.email, false, _emailTextController),
          const SizedBox(height: 20),
          MaterialButton(
            onPressed: passwordReset,
            // ignore: sort_child_properties_last
            child: const Text('Reset Password'),
            color: Colors.lightBlue,
          ),
        ],
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
}

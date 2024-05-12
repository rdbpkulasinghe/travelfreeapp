import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travelfreeapp/screens/question_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelfreeapp/screens/signin_screen.dart';

class SettingPage extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const SettingPage({Key? key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  String name = '';
  String email = '';

  bool _isEditingName = false;
  bool _isEditingEmail = false;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    getUserDataFromFirestore();
  }

  Future<void> getUserDataFromFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> userData =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        setState(() {
          name = userData.get('username');
          email = userData.get('email');
          _nameController.text = name;
          _emailController.text = email;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 65, 105, 225),
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _signOut();
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileImage(),
              const SizedBox(height: 16),
              _buildNameField(),
              const SizedBox(height: 16),
              _buildEmailField(),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QuestionPage(),
                    ),
                  );
                },
                child: const Text('Review Questions'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: () {
        _pickImage();
      },
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[200],
        backgroundImage:
            _imageFile != null ? FileImage(File(_imageFile!.path)) : null,
        child: _imageFile == null
            ? const Icon(
                Icons.add_a_photo,
                size: 50,
              )
            : null,
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Widget _buildNameField() {
    if (_isEditingName) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Name',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              saveName();
            },
            child: const Text('Save'),
          ),
        ],
      );
    } else {
      return ListTile(
        title: const Text('Name'),
        subtitle: Text(name),
        onTap: () {
          setState(() {
            _isEditingName = true;
          });
        },
      );
    }
  }

  Widget _buildEmailField() {
    if (_isEditingEmail) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Email',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              saveEmail();
            },
            child: const Text('Save'),
          ),
        ],
      );
    } else {
      return ListTile(
        title: const Text('Email'),
        subtitle: Text(email),
        onTap: () {
          setState(() {
            _isEditingEmail = true;
          });
        },
      );
    }
  }

  void saveName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'username': _nameController.text,
        });
        setState(() {
          name = _nameController.text;
          _isEditingName = false;
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Name saved successfully')));
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error saving name: $e");
    }
  }

  void saveEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'email': _emailController.text,
        });
        setState(() {
          email = _emailController.text;
          _isEditingEmail = false;
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email saved successfully')));
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error saving email: $e");
    }
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to the sign-in screen
      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
        (route) => false,
      );
    } catch (e) {
      // Handle sign-out errors
      // ignore: avoid_print
      print("Error signing out: $e");
    }
  }
}

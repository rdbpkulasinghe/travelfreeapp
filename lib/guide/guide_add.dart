import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GuideAddPage extends StatefulWidget {
  const GuideAddPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _GuideAddPageState createState() => _GuideAddPageState();
}

class _GuideAddPageState extends State<GuideAddPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController =
      TextEditingController(); // New email controller

  File? _profileImage;
  File? _letterImage;

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the guide\'s name';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the guide\'s address';
    }
    return null;
  }

  String? _validateNIC(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the guide\'s NIC';
    }
    return null;
  }

  String? _validateTelephone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the guide\'s telephone number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the guide\'s email address';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> _getImage(ImageSource source, bool isProfileImage) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        if (isProfileImage) {
          _profileImage = File(pickedFile.path);
        } else {
          _letterImage = File(pickedFile.path);
        }
      }
    });
  }

  Future<String?> _getCurrentUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.email;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUserEmail().then((email) {
      if (email != null) {
        _emailController.text = email;
      }
    });
  }

  Future<void> _saveDataToFirebase() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? profileImageUrl;
        String? letterImageUrl;

        // Upload profile image to Firebase Storage
        if (_profileImage != null) {
          var profileImageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('${DateTime.now()}.jpg');
          await profileImageRef.putFile(_profileImage!);
          profileImageUrl = await profileImageRef.getDownloadURL();
        }

        // Upload letter image to Firebase Storage
        if (_letterImage != null) {
          var letterImageRef = FirebaseStorage.instance
              .ref()
              .child('letter_images')
              .child('${DateTime.now()}.jpg');
          await letterImageRef.putFile(_letterImage!);
          letterImageUrl = await letterImageRef.getDownloadURL();
        }

        // Save guide data along with image URLs to Firestore
        await FirebaseFirestore.instance.collection('guides').add({
          'name': _nameController.text,
          'address': _addressController.text,
          'nic': _nicController.text,
          'telephone': _telephoneController.text,
          'email': _emailController.text, // Include email address
          'profileImageUrl': profileImageUrl,
          'letterImageUrl': letterImageUrl,
        });

        // Reset the form and images after successful data submission
        _formKey.currentState!.reset();
        setState(() {
          _profileImage = null;
          _letterImage = null;
        });

        // Show success message
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Guide added successfully'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (error) {
        // ignore: avoid_print
        print('Error saving data to Firestore: $error');
        // Show error message
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to save guide. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 65, 105, 225),
        title: const Text('Add Guide'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: _validateName,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: _validateAddress,
              ),
              TextFormField(
                controller: _nicController,
                decoration: const InputDecoration(labelText: 'NIC'),
                validator: _validateNIC,
              ),
              TextFormField(
                controller: _telephoneController,
                decoration: const InputDecoration(labelText: 'Telephone'),
                validator: _validateTelephone,
              ),
              TextFormField(
                controller: _emailController, // Add controller for email field
                decoration: const InputDecoration(labelText: 'Email'),
                validator: _validateEmail, // Add email validation
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _getImage(ImageSource.gallery, true);
                },
                child: Text(_profileImage != null
                    ? 'Change Profile Picture'
                    : 'Add Profile Picture'),
              ),
              if (_profileImage != null)
                Image.file(
                  _profileImage!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _getImage(ImageSource.gallery, false); // Change button action
                },
                child: Column(
                  children: [
                    Text(
                      _letterImage != null
                          ? 'Change Confirmation Letter'
                          : 'Upload Confirmation Letter',
                    ),
                    Text(
                      'Please upload a confirmation letter from the village officer',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (_letterImage != null)
                Text(
                  _letterImage!.path.split('/').last,
                  style: const TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveDataToFirebase();
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text(
                              'Please fill out all required fields.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text('Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

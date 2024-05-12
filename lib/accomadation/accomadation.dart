import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HotelAddPage extends StatefulWidget {
  const HotelAddPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HotelAddPageState createState() => _HotelAddPageState();
}

class _HotelAddPageState extends State<HotelAddPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController(); // Added
  // Added

  File? _image;

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the hotel name';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the hotel address';
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

  String? _validateContact(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the hotel contact number';
    }
    return null;
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _saveDataToFirebase() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? imageUrl;

        // Upload image to Firebase Storage
        if (_image != null) {
          var imageRef = FirebaseStorage.instance
              .ref()
              .child('hotel_images')
              .child('${DateTime.now()}.jpg');
          await imageRef.putFile(_image!);
          imageUrl = await imageRef.getDownloadURL();
        }

        // Save hotel data along with image URL and status to Firestore
        await FirebaseFirestore.instance.collection('hotels').add({
          'name': _nameController.text,
          'address': _addressController.text,
          'contact': _contactController.text,
          'description': _descriptionController.text, // Added
          'email': _emailController.text,
          'imageUrl': imageUrl,
          'status': 'pending', // Added
        });

        // Reset the form and image after successful data submission
        _formKey.currentState!.reset();
        setState(() {
          _image = null;
        });

        // Show success message
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Hotel added successfully'),
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
              content: Text('Failed to save hotel. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 65, 105, 225),
        title: const Text('Add Hotel'),
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
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact Number'),
                validator: _validateContact,
              ),
              TextFormField(
                controller: _emailController, // Add controller for email field
                decoration: const InputDecoration(labelText: 'Email'),
                validator: _validateEmail, // Add email validation
              ),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Description'), // Added
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _getImage(ImageSource.gallery);
                },
                child: Text(_image != null ? 'Change Image' : 'Upload Image'),
              ),
              if (_image != null)
                Image.file(
                  _image!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
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

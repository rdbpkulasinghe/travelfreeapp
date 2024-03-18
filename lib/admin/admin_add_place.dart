import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelfreeapp/admin/location_input.dart';
import 'package:travelfreeapp/admin/place_location.dart';

class AdminAddPlacePage extends StatefulWidget {
  const AdminAddPlacePage({Key? key}) : super(key: key);

  @override
  _AdminAddPlacePageState createState() => _AdminAddPlacePageState();
}

class _AdminAddPlacePageState extends State<AdminAddPlacePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _informationController = TextEditingController();
  final TextEditingController _localPriceController = TextEditingController();
  final TextEditingController _foreignPriceController = TextEditingController();
  final TextEditingController _childPriceController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _openHoursController = TextEditingController();

  List<File> _selectedImages = [];
  List<String> _imageUrls = [];

  String _selectedLocalCurrency = 'Dollars';
  String _selectedForeignCurrency = 'Dollars';
  String _selectedChildCurrency = 'Dollars';
  String _selectedDistrict = 'Colombo'; // Default value

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  PlaceLocation? _selectedLocation;

  Future<void> addDataToFirestore() async {
    if (!_isLocationSelected() ||
        _nameController.text.isEmpty ||
        _informationController.text.isEmpty ||
        _localPriceController.text.isEmpty ||
        _foreignPriceController.text.isEmpty ||
        _childPriceController.text.isEmpty ||
        _contactNumberController.text.isEmpty ||
        _openHoursController.text.isEmpty ||
        _selectedImages.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('All fields are required.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      await uploadImagesToStorage();

      await firestore.collection('places').add({
        'name': _nameController.text,
        'information': _informationController.text,
        'localPrice': _localPriceController.text,
        'localCurrency': _selectedLocalCurrency,
        'foreignPrice': _foreignPriceController.text,
        'foreignCurrency': _selectedForeignCurrency,
        'childPrice': _childPriceController.text,
        'childCurrency': _selectedChildCurrency,
        'contactNumber': _contactNumberController.text,
        'openHours': _openHoursController.text,
        'address': _selectedLocation!.address,
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'district': _selectedDistrict,
        'imageUrls': _imageUrls,
      });

      _nameController.clear();
      _informationController.clear();
      _localPriceController.clear();
      _foreignPriceController.clear();
      _childPriceController.clear();
      _contactNumberController.clear();
      _openHoursController.clear();
      setState(() {
        _selectedImages = [];
        _imageUrls = [];
      });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Place added successfully.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to save place. Please try again.'),
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
  }

  bool _isLocationSelected() {
    return _selectedLocation != null;
  }

  Future<void> uploadImagesToStorage() async {
    for (var imageFile in _selectedImages) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final reference = storage.ref().child('images/$fileName');
      final uploadTask = reference.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      _imageUrls.add(downloadUrl);
    }
  }

  Future<void> _pickImagesFromGallery() async {
    final picker = ImagePicker();
    final pickedImages = await picker.pickMultiImage();
    // ignore: unnecessary_null_comparison
    if (pickedImages != null) {
      setState(() {
        _selectedImages
            .addAll(pickedImages.map((pickedImage) => File(pickedImage.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Place'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _informationController,
                decoration: const InputDecoration(labelText: 'Information'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _localPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Local Visitors Price'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _selectedLocalCurrency,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLocalCurrency = newValue!;
                      });
                    },
                    items: <String>['Dollars', 'Rupees']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _foreignPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Foreign Visitors Price'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _selectedForeignCurrency,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedForeignCurrency = newValue!;
                      });
                    },
                    items: <String>['Dollars', 'Rupees']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _childPriceController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Child Price'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _selectedChildCurrency,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedChildCurrency = newValue!;
                      });
                    },
                    items: <String>['Dollars', 'Rupees']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _contactNumberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Contact Number'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _openHoursController,
                decoration: const InputDecoration(labelText: 'Open Hours'),
              ),
              const SizedBox(height: 10),
              // add location input
              LocationInput(
                onSelectLocation: (location) {
                  setState(() {
                    _selectedLocation = location;
                  });
                },
              ),
              const SizedBox(height: 10),
              // Dropdown to select district
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedDistrict,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDistrict = newValue!;
                        });
                      },
                      items: <String>[
                        'Ampara', 'Anuradhapura', 'Badulla', 'Batticaloa',
                        'Colombo', 'Galle', 'Gampaha', 'Hambantota', 'Jaffna',
                        'Kalutara', 'Kandy', 'Kegalle', 'Kilinochchi',
                        'Kurunegala', 'Mannar', 'Matale', 'Matara',
                        'Moneragala', 'Mullaitivu', 'Nuwara Eliya',
                        'Polonnaruwa', 'Puttalam', 'Ratnapura', 'Trincomalee',
                        'Vavuniya',
                        // Add more districts if needed
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImagesFromGallery,
                child: const Text('Select Images from Gallery'),
              ),
              const SizedBox(height: 20),
              if (_selectedImages.isNotEmpty)
                Column(
                  children: _selectedImages.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final File image = entry.value;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(image),
                        ),
                        ElevatedButton(
                          onPressed: () => _removeImage(index),
                          child: const Text('Remove Image'),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedLocation = null;
                      });
                    },
                    child: const Text('Remove Place'),
                  ),
                  ElevatedButton(
                    onPressed: addDataToFirestore,
                    child: const Text('Save Place'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

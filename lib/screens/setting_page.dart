import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String name = 'John Doe'; // Replace with actual user data
  String email = 'john.doe@example.com'; // Replace with actual user data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text('Profile'),
      ),
      body: Container(
        color: Colors.lightBlue, // Set the background color to light blue
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: const Text('Name'),
                subtitle: Text(name),
                onTap: () {
                  // Add logic to navigate to edit name page
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => EditNamePage()));
                },
              ),
              ListTile(
                title: const Text('Email'),
                subtitle: Text(email),
                onTap: () {
                  // Add logic to navigate to edit email page
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => EditEmailPage()));
                },
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Emergency Services',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              buildEmergencyServiceTile(
                'Fuel Stations',
                onTap: () {
                  // Add logic to navigate to fuel stations page
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => FuelStationsPage()));
                },
              ),
              buildEmergencyServiceTile(
                'Police Stations',
                onTap: () {
                  // Add logic to navigate to police stations page
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => PoliceStationsPage()));
                },
              ),
              buildEmergencyServiceTile(
                'Hospitals',
                onTap: () {
                  // Add logic to navigate to hospitals page
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => HospitalsPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile buildEmergencyServiceTile(String title,
      {required VoidCallback onTap}) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
    );
  }
}

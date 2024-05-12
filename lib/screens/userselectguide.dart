// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:travelfreeapp/screens/home_page.dart';

class UserSelectguide extends StatelessWidget {
  const UserSelectguide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers, unused_local_variable
    final CarouselController _carouselController = CarouselController();
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User is not logged in'),
        ),
      );
    }

    // Create a GlobalKey for the ScaffoldMessenger
    final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
        GlobalKey<ScaffoldMessengerState>();

    return Scaffold(
      key: scaffoldMessengerKey,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 65, 105, 225),
        title: const Text('User select place'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('userselectguide')
            .doc(user.uid)
            .collection('guides')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No places found'));
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var guideDocument = snapshot.data!.docs[index];
              var guideId = guideDocument.id;
              var guideData = guideDocument.data() as Map<String, dynamic>;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SizedBox(
                          width: 130,
                          height: 130,
                          child: ClipOval(
                            child: guideData['profileImageUrl'] != null
                                ? Image.network(
                                    guideData['profileImageUrl']!,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons
                                    .person), // Placeholder if profile image is null
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Name: ${guideData['name'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Address: ${guideData['address'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'NIC: ${guideData['nic'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Telephone: ${guideData['telephone'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Email: ${guideData['email'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      DropdownButton<String>(
                        items: const [
                          DropdownMenuItem(
                            // ignore: sort_child_properties_last
                            child: Text('Select Dates'),
                            value: 'select_dates',
                          ),
                        ],
                        onChanged: (String? value) async {
                          if (value == 'select_dates') {
                            final pickedDateRange = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (pickedDateRange != null) {
                              final DateFormat formatter =
                                  DateFormat('yyyy-MM-dd');
                              final String startDateFormatted =
                                  formatter.format(pickedDateRange.start);
                              final String endDateFormatted =
                                  formatter.format(pickedDateRange.end);

                              // Get traveler email
                              final user = FirebaseAuth.instance.currentUser;
                              final travelerEmail = user?.email ?? '';

                              // Save selected dates with guide and traveler details
                              await FirebaseFirestore.instance
                                  .collection('guides')
                                  .doc(guideId)
                                  .update({
                                'selectedDates': FieldValue.arrayUnion([
                                  {
                                    'start': startDateFormatted,
                                    'end': endDateFormatted,
                                    'guideEmail': guideData['email'],
                                    // Add traveler email
                                    'travelerEmail': travelerEmail,
                                  }
                                ])
                              });

                              // ignore: avoid_print
                              print(
                                  'Start Date: $startDateFormatted, End Date: $endDateFormatted');
                            }
                          }
                        },
                        hint: const Text('Select Dates'),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () async {
                              // Get the currently logged in user
                              User? user = FirebaseAuth.instance.currentUser;

                              if (user != null) {
                                String userId = user.uid;
                                // Reference to the subcollection under the user's document
                                CollectionReference userPlacesRef =
                                    FirebaseFirestore.instance
                                        .collection('userselectplace')
                                        .doc(userId)
                                        .collection('places');

                                try {
                                  // Delete the document corresponding to the current place
                                  await userPlacesRef
                                      .doc(snapshot.data!.docs[index].id)
                                      .delete();

                                  // Show notification or perform any other action upon successful removal
                                  scaffoldMessengerKey.currentState
                                      ?.showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Place removed successfully!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } catch (error) {
                                  // Show error message if deletion fails
                                  scaffoldMessengerKey.currentState
                                      ?.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Failed to remove place: $error'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  // ignore: avoid_print
                                  print('Failed to remove place: $error');
                                }
                              } else {
                                // ignore: avoid_print
                                print('User is not logged in.');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Remove',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

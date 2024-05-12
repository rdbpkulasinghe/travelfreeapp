import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travelfreeapp/reusable_widget/bottomnavbar.dart'; // Import FirebaseAuth

class ApprovedGuideListPage extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const ApprovedGuideListPage({Key? key});
  Future<void> addSelectedPlace(
      BuildContext context, Map<String, dynamic> hotel) async {
    // Get the currently logged in user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;
      try {
        // Reference to the subcollection under the user's document
        CollectionReference userPlacesRef = FirebaseFirestore.instance
            .collection('userselectguide')
            .doc(userId)
            .collection('guides');
        // Check if the place already exists in user's selected places
        QuerySnapshot querySnapshot =
            await userPlacesRef.where('name', isEqualTo: hotel['name']).get();

        // ignore: avoid_print
        print(querySnapshot.docs);

        if (querySnapshot.docs.isNotEmpty) {
          // Place already exists, show a message
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Place already added!'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        await userPlacesRef.add(hotel);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Place added successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (error) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save place: $error'),
            duration: const Duration(seconds: 2), // Adjust as needed
          ),
        );

        // ignore: avoid_print
        print('Failed to save place: $error');
      }
    } else {
      // ignore: avoid_print
      print('User is not logged in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 65, 105, 225),
        title: const Text('Approved Guide List'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('guides')
                  .where('approved', isEqualTo: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No approved guides found'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var guideDocument = snapshot.data!.docs[index];
                    var guideId = guideDocument.id;
                    var guideData =
                        guideDocument.data() as Map<String, dynamic>;
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
                                  final pickedDateRange =
                                      await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 365)),
                                  );
                                  if (pickedDateRange != null) {
                                    final DateFormat formatter =
                                        DateFormat('yyyy-MM-dd');
                                    final String startDateFormatted =
                                        formatter.format(pickedDateRange.start);
                                    final String endDateFormatted =
                                        formatter.format(pickedDateRange.end);

                                    // Get traveler email
                                    final user =
                                        FirebaseAuth.instance.currentUser;
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
                                  onPressed: () {
                                    addSelectedPlace(
                                        context, guideData); // Updated
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Add',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

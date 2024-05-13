import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ApprovedHotelListPage extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const ApprovedHotelListPage({Key? key});
  Future<void> addSelectedPlace(
      BuildContext context, Map<String, dynamic> hotel) async {
    // Get the currently logged in user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;
      try {
        // Reference to the subcollection under the user's document
        CollectionReference userPlacesRef = FirebaseFirestore.instance
            .collection('userselecthotel')
            .doc(userId)
            .collection('hotels');
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
    // ignore: no_leading_underscores_for_local_identifiers
    final CarouselController _carouselController = CarouselController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 65, 105, 225),
        title: const Text('Approved Hotel List'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('hotels')
                  .where('status', isEqualTo: 'approved')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hotels found'));
                }
                // Filter approved hotels
                var approvedHotels = snapshot.data!.docs
                    .where((doc) => doc['status'] == 'approved')
                    .toList();
                if (approvedHotels.isEmpty) {
                  return const Center(child: Text('No approved hotels found'));
                }
                // ignore: avoid_printrun
                print(approvedHotels);

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: approvedHotels.length,
                  itemBuilder: (context, index) {
                    var hotelDocument = snapshot.data!.docs[index];
                    var hotelId = hotelDocument.id;
                    // ignore: avoid_print
                    print(hotelId);
                    var hotel =
                        approvedHotels[index].data() as Map<String, dynamic>;
                    String image = hotel['imageUrl'];
                    List<String> images = [];
                    images.add(image);
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CarouselSlider(
                                carouselController: _carouselController,
                                options: CarouselOptions(
                                  height: 200.0,
                                  aspectRatio: 16 / 9,
                                  viewportFraction: 0.8,
                                  initialPage: 0,
                                  enableInfiniteScroll: true,
                                  reverse: false,
                                  autoPlay: false, // Disable auto play
                                  enlargeCenterPage: true,
                                  scrollDirection: Axis.horizontal,
                                ),
                                items: images.map((imageUrl) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          image: DecorationImage(
                                            image: NetworkImage(imageUrl),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                _carouselController
                                                    .previousPage();
                                              },
                                              icon: const Icon(
                                                  Icons.arrow_back_ios,
                                                  color: Colors.white),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                _carouselController.nextPage();
                                              },
                                              icon: const Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Name: ${hotel['name'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Address: ${hotel['address'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Email: ${hotel['email'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Contact: ${hotel['contact'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Description: ${hotel['description'] ?? 'N/A'}',
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
                                    // ignore: avoid_print
                                    print(hotelId);
                                    // Save selected dates with guide and traveler details
                                    await FirebaseFirestore.instance
                                        .collection('hotels')
                                        .doc(hotelId)
                                        .update({
                                      'selectedDates': FieldValue.arrayUnion([
                                        {
                                          'start': startDateFormatted,
                                          'end': endDateFormatted,
                                          'hotelEmail': hotel['email'],
                                          'travelerEmail': travelerEmail,
                                        }
                                      ])
                                    }).onError((error, stackTrace) =>
                                            // ignore: avoid_print
                                            print(error));

                                    // ignore: avoid_print
                                    print(
                                        'Start45Date: $startDateFormatted, End Date: $endDateFormatted');
                                  }
                                }
                              },
                              hint: const Text('Select Dates'),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    //getRecommendedPlaces();
                                    addSelectedPlace(context, hotel); // Updated
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
    );
  }
}

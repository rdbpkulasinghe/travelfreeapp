import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
//import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:travelfreeapp/screens/home_page.dart';
import 'package:travelfreeapp/screens/location_details.dart';
import 'package:travelfreeapp/screens/map_page.dart';
//import 'package:travelfreeapp/screens/map_page.dart';

class UserSelectAllPlace extends StatelessWidget {
  const UserSelectAllPlace({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    final CarouselController _carouselController = CarouselController();
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User is not logged in'),
        ),
      );
    }

    final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
        GlobalKey<ScaffoldMessengerState>();

    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        key: scaffoldMessengerKey,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 65, 105, 225),
          title: const Text('User select place'),
          bottom: const TabBar(
            labelColor: Colors.white, // Set the text color of selected tab

            tabs: [
              Tab(
                child: Text(
                  'Places',
                  style:
                      TextStyle(color: Colors.white), // Text color for this tab
                ),
              ),
              Tab(
                child: Text(
                  'Hotels',
                  style:
                      TextStyle(color: Colors.white), // Text color for this tab
                ),
              ),
              Tab(
                child: Text(
                  'Guides',
                  style:
                      TextStyle(color: Colors.white), // Text color for this tab
                ),
              ),
            ],
          ),
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
        body: TabBarView(
          children: [
            // UserSelectPlace Screen
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('userselectplace')
                  .doc(user.uid)
                  .collection('places')
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
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var place = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;

                    List<String> imageUrls =
                        List<String>.from(place['imageUrls']);
                    return Column(
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
                            items: imageUrls.map((imageUrl) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(8.0),
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
                                            _carouselController.previousPage();
                                          },
                                          icon: const Icon(Icons.arrow_back_ios,
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
                        ListTile(
                          title: Align(
                            alignment: Alignment.center,
                            child: Text(
                              place['name'] ?? 'N/A',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${place['information'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${place['details'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Tel no: ${place['contactNumber'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'District: ${place['district'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Location: ${place['location'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Local Price: ${place['localPrice'] ?? 'N/A'} ${place['localCurrency'] ?? ''}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Foreign Price: ${place['foreignPrice'] ?? 'N/A'} ${place['foreignCurrency'] ?? ''}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Child Price: ${place['childPrice'] ?? 'N/A'} ${place['childCurrency'] ?? ''}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Notific(
                                            doc: place,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'More',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MapPage(
                                            latitude: place['latitude'],
                                            longitude: place['longitude'],
                                            address: place['address'],
                                            placeName: place['name'],
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.map,
                                        color: Colors.blue),
                                    label: const Text(
                                      'Map',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Get the currently logged in user
                                      User? user =
                                          FirebaseAuth.instance.currentUser;

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
                                              .doc(
                                                  snapshot.data!.docs[index].id)
                                              .delete();

                                          // Show notification or perform any other action upon successful removal
                                          scaffoldMessengerKey.currentState
                                              ?.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Place removed successfully!'),
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
                                              duration:
                                                  const Duration(seconds: 2),
                                            ),
                                          );
                                          // ignore: avoid_print
                                          print(
                                              'Failed to remove place: $error');
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
                        const Divider(),
                      ],
                    );
                  },
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('userselecthotel')
                  .doc(user.uid)
                  .collection('hotels')
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
                    var hotelDocument = snapshot.data!.docs[index];
                    var hotelId = hotelDocument.id;
                    // ignore: avoid_print
                    print(hotelId);
                    var hotel = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    List<String> images = [];

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
                                items: images.map((imageUrls) {
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
                                            image: NetworkImage(imageUrls),
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
                            Text(
                              'Rating: ${hotel['rating'] ?? 'N/A'}',
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
                                        'StartDate: $startDateFormatted, End Date: $endDateFormatted');
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
                                  onPressed: () async {
                                    // Get the currently logged in user
                                    User? user =
                                        FirebaseAuth.instance.currentUser;

                                    if (user != null) {
                                      String userId = user.uid;
                                      // Reference to the subcollection under the user's document
                                      CollectionReference userPlacesRef =
                                          FirebaseFirestore.instance
                                              .collection('userselecthotel')
                                              .doc(userId)
                                              .collection('hotels');

                                      try {
                                        // Delete the document corresponding to the current place
                                        await userPlacesRef
                                            .doc(snapshot.data!.docs[index].id)
                                            .delete();

                                        // Show notification or perform any other action upon successful removal
                                        scaffoldMessengerKey.currentState
                                            ?.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Place removed successfully!'),
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
                                            duration:
                                                const Duration(seconds: 2),
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
            StreamBuilder<QuerySnapshot>(
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
                                  onPressed: () async {
                                    // Get the currently logged in user
                                    User? user =
                                        FirebaseAuth.instance.currentUser;

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
                                            content: Text(
                                                'Place removed successfully!'),
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
                                            duration:
                                                const Duration(seconds: 2),
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
            // HomePage Screen
          ],
        ),
      ),
    );
  }
}

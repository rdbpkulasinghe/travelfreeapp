// ignore_for_file: unused_local_variable

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travelfreeapp/reusable_widget/bottomnavbar.dart';
import 'package:travelfreeapp/screens/location_details.dart';
import 'package:travelfreeapp/screens/map_page.dart';
import 'package:travelfreeapp/screens/userselect.dart';
import 'package:travelfreeapp/screens/welcomepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class HomePage extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const HomePage({super.key});

  Future<void> addSelectedPlace(
      BuildContext context, Map<String, dynamic> place) async {
    // Get the currently logged in user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;
      try {
        // Reference to the subcollection under the user's document
        CollectionReference userPlacesRef = FirebaseFirestore.instance
            .collection('userselectplace')
            .doc(userId)
            .collection('places');
        // Check if the place already exists in user's selected places
        QuerySnapshot querySnapshot =
            await userPlacesRef.where('name', isEqualTo: place['name']).get();

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
        await userPlacesRef.add(place);
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

  Future<QuerySnapshot> getRecommendedPlaces() async {
    List ans = await callApi();
    if (ans.isNotEmpty) {
      return FirebaseFirestore.instance
          .collection('places')
          .where('tags', arrayContainsAny: ans)
          .get();
    }
    return FirebaseFirestore.instance.collection('places').get();
  }

  Future<List> callApi() async {
    User? user = FirebaseAuth.instance.currentUser;
    List ans = [];
    if (user != null) {
      String userId = user.uid;
      DocumentSnapshot answers = await FirebaseFirestore.instance
          .collection('answers')
          .doc(userId)
          .get();
      if (answers.data() != null) {
        // ignore: avoid_print

        // ignore: avoid_print
        print(answers.data().toString());
        // json.encode(answers.data());
        Map<String, dynamic> jsonMap = json.decode(json.encode(answers.data()));
        if (jsonMap['Main travel goals'] != null) {
          ans.addAll(answers.get('Main travel goals'));
        }
        if (jsonMap['Destination preferences'] != null) {
          ans.addAll(answers.get('Destination preferences'));
        }
        if (jsonMap['Dietary preferences'] != null) {
          ans.addAll(answers.get('Dietary preferences'));
        }
        if (jsonMap['Traveler type'] != null) {
          ans.addAll(answers.get('Traveler type'));
        }
        if (jsonMap['Local or Foreigner'] != null) {
          ans.addAll(answers.get('Local or Foreigner'));
        }
        // ans.addAll(answers.get('Destination preferences'));
        // ans.addAll(answers.get('Dietary preferences'));
        // ans.addAll(answers.get('Traveler type'));
        // ans.addAll(answers.get('Local or Foreigner'));
      }
    }
    return ans;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    final CarouselController _carouselController = CarouselController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 65, 105, 225),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QuestionnaireApp()),
            );
          },
        ),
        title: const Icon(
          Icons.home,
          color: Colors.black,
          size: 36,
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserSelectAllPlace(),
                ),
              );
            },
            icon: const Icon(Icons.place, color: Colors.white, size: 28),
            label: const Text(
              'User',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: getRecommendedPlaces(),
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
              var place =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              var id = place['id'];

              List<String> imageUrls = List<String>.from(place['imageUrls']);
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
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
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
                                    icon: const Icon(Icons.arrow_forward_ios,
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
                          'Location: ${place['address'] ?? 'N/A'}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Notific(doc: place),
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
                              icon: const Icon(Icons.map, color: Colors.blue),
                              label: const Text(
                                'Map',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          //getRecommendedPlaces();
                          addSelectedPlace(context,
                              place); // Call the function to add the selected place
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
                  const Divider(), //we use this for divide each place
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: HomePage(),
  ));
}

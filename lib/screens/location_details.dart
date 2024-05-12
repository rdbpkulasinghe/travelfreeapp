import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:travelfreeapp/screens/map_page.dart';

class BusinessInfoWidget extends StatelessWidget {
  final String title;
  final String content;
  final String address; // Add address parameter
  final bool showMapButton;
  final VoidCallback? onMapButtonPressed;

  const BusinessInfoWidget({
    super.key,
    required this.title,
    required this.content,
    required this.address, // Include address parameter
    this.showMapButton = false,
    this.onMapButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Colors.lightBlueAccent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          Text(
            'Address: $address', // Display address
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          if (showMapButton)
            ElevatedButton(
              onPressed: onMapButtonPressed,
              child: const Text('View on Map'),
            ),
        ],
      ),
    );
  }
}

class Notific extends StatefulWidget {
  // const Notific({Key? key}) : super(key: key);

  // ignore: prefer_typing_uninitialized_variables
  final doc;
  // final String title = "dfff";

  const Notific({super.key, required this.doc});

  @override
  State<Notific> createState() => _NotificState();
}

class _NotificState extends State<Notific> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final List<String> movingImages = [
    'assets/images/ninearch1.jpg',
    'assets/images/ninearch2.jpg',
    'assets/images/ninearch3.jpg',
    'assets/images/ninearch4.jpg',
    // Add more moving image paths as needed
  ];

  final CarouselController _carouselController = CarouselController();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> imageUrls = widget.doc['imageUrls'];
    List<String> stringList =
        imageUrls.map((element) => element.toString()).toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Details'),
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0, // Remove shadow
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 200.0,
                child: Stack(
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
                        items: stringList.map((imageUrl) {
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
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: _firestore
                      .collection('places')
                      .doc(widget.doc['id'])
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // Show loading indicator while data is being fetched
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      if (snapshot.hasData && snapshot.data != null) {
                        var data = snapshot.data;
                        return BusinessInfoWidget(
                          title: widget.doc['name'],
                          content: widget.doc['information'],
                          address: widget.doc['address'],
                          showMapButton: true,
                          onMapButtonPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MapPage(
                                  latitude: 0.0, // Provide latitude value here
                                  longitude:
                                      0.0, // Provide longitude value here
                                  address: '', // Provide address value here
                                  placeName:
                                      'Your Place Name', // Provide place name here
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Text('No data available');
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
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
  const Notific({Key? key}) : super(key: key);

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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    PageView.builder(
                      controller: _pageController,
                      itemCount: movingImages.length,
                      itemBuilder: (context, index) {
                        return Center(
                          child: Image.asset(
                            movingImages[index],
                            width: double.infinity,
                            height: 300.0,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (_currentIndex > 0) {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (_currentIndex < movingImages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: BusinessInfoWidget(
                  title: ' Nine Arch Bridge',
                  content:
                      "Welcome to the Nine Arch Bridge in Ella, Sri Lanka – a breathtaking blend of history and natural splendor. Built in 1921 during the British colonial era, this iconic bridge boasts nine picturesque arches, each a testament to architectural finesse.\n\n"
                      "Why visit? The Nine Arch Bridge isn't just a crossing, it's a journey into a realm where lush tea plantations and mist-covered hills create a mesmerizing backdrop. As you stroll across this living masterpiece, let the echoes of history and the panoramic views of the Ella Valley captivate your senses.\n\n"
                      "Top features:\n\n"
                      "Architectural Marvel: Marvel at the nine gracefully crafted arches that stand as a timeless symbol of craftsmanship.\n\n"
                      "Scenic Beauty: Immerse yourself in the surrounding tea plantations and verdant hills, making every step a visual delight.\n\n"
                      "Historical Charm: Step back in time and feel the colonial legacy as you explore this heritage site.\n\n"
                      "Pro Tip: Plan your visit during sunrise or sunset for a magical experience. Capture the moments, breathe in the fresh mountain air, and let the Nine Arch Bridge leave an indelible mark on your travel memories.Ready to embark on a journey like no other? Explore the Nine Arch Bridge – where history meets natural beauty. Your adventure awaits!\n\n"
                      "ContactNumber: 0773695125\n"
                      "Open Hours: 24 hours\n",
                  address: 'Your Address Here', // Provide the address
                  showMapButton: true,
                  onMapButtonPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MapPage(
                          latitude: 0.0, // Provide latitude value here
                          longitude: 0.0,
                          address: '', // Provide longitude value here
                          placeName:
                              'Your Place Name', // Provide place name here
                        ),
                      ),
                    );
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travelfreeapp/reusable_widget/bottomnavbar.dart';

class ApprovedGuideListPage extends StatelessWidget {
  const ApprovedGuideListPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                    var guide = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>; // Explicit cast
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
                                  child: guide['profileImageUrl'] != null
                                      ? Image.network(
                                          guide['profileImageUrl']!,
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
                              'Name: ${guide['name'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Address: ${guide['address'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'NIC: ${guide['nic'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Telephone: ${guide['telephone'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Email: ${guide['email'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Add button functionality
                                    // You can use this onPressed callback to add guide
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary:
                                        Colors.lightBlue, // Background color
                                  ),
                                  child: const Text('Add'),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    // Remove button functionality
                                    // You can use this onPressed callback to remove guide
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary:
                                        Colors.lightBlue, // Background color
                                  ),
                                  child: const Text('Remove'),
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
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

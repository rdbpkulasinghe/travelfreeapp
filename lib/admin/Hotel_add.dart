import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GuideListPage extends StatelessWidget {
  const GuideListPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide List'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('guides').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No guides found'));
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
                            Text('Name: ${guide['name'] ?? 'N/A'}'),
                            Text('Address: ${guide['address'] ?? 'N/A'}'),
                            Text('NIC: ${guide['nic'] ?? 'N/A'}'),
                            Text('Telephone: ${guide['telephone'] ?? 'N/A'}'),
                            Text('Email: ${guide['email'] ?? 'N/A'}'),
                            if (guide['profileImageUrl'] != null)
                              Image.network(
                                guide['profileImageUrl']!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            if (guide['letterImageUrl'] != null)
                              Image.network(
                                guide['letterImageUrl']!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
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
            ElevatedButton(
              onPressed: () {
                // Your onPressed function
              },
              child: const Text('Your Button Text'),
            ),
          ],
        ),
      ),
    );
  }
}

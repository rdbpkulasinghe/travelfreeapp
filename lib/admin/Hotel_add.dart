// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HotelListPage extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const HotelListPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 65, 105, 225),
        title: const Text('Hotel List'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('hotels').snapshots(),
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
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var hotel = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Your hotel details UI here
                            Center(
                              child: SizedBox(
                                width: 120,
                                height: 120,
                                child: ClipOval(
                                  child: hotel['imageUrl'] != null
                                      ? Image.network(
                                          hotel['imageUrl'],
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons
                                          .hotel), // Placeholder if image is null
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ), // Add spacing between image and text
                            Text(
                              'Name: ${hotel['name'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 18,
                              ), // Increase text size
                            ),
                            Text(
                              'Address: ${hotel['address'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 18,
                              ), // Increase text size
                            ),
                            Text(
                              'Email: ${hotel['email'] ?? 'N/A'}',
                              style: const TextStyle(
                                  fontSize: 18), // Increase text size
                            ),
                            Text(
                              'Contact: ${hotel['contact'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 18,
                              ), // Increase text size
                            ),
                            Text(
                              ' ${hotel['description'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 18,
                              ), // Increase text size
                            ),
                            Text(
                              'Rating: ${hotel['rating'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 18,
                              ), // Increase text size
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    // Handle approving a hotel
                                    if (hotel.containsKey('status') &&
                                        hotel['status'] == 'pending') {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('hotels')
                                            .doc(snapshot.data!.docs[index].id)
                                            .update({'status': 'approved'});
                                      } catch (error) {
                                        // ignore: avoid_print
                                        print(
                                            'Error updating hotel status: $error');
                                        // Handle error updating status
                                      }
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Error'),
                                            content: const Text(
                                                'This hotel has already been approved.'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: const Text('Approve'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Handle removing a hotel
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirmation'),
                                          content: const Text(
                                              'Are you sure you want to remove this hotel?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                try {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('hotels')
                                                      .doc(snapshot
                                                          .data!.docs[index].id)
                                                      .delete();
                                                  // ignore: use_build_context_synchronously
                                                  Navigator.of(context).pop();
                                                } catch (error) {
                                                  // ignore: avoid_print
                                                  print(
                                                      'Error deleting hotel: $error');
                                                  // Handle error deleting hotel
                                                }
                                              },
                                              child: const Text('Confirm'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
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
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

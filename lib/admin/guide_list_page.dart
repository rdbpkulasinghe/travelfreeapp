import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GuideListPage extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const GuideListPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 65, 105, 225),
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
                            Center(
                              child: SizedBox(
                                width: 120,
                                height: 120,
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
                                height:
                                    8), // Add spacing between profile picture and text
                            Text(
                              'Name: ${guide['name'] ?? 'N/A'}',
                              style: const TextStyle(
                                  fontSize: 18), // Increase text size
                            ),
                            Text(
                              'Address: ${guide['address'] ?? 'N/A'}',
                              style: const TextStyle(
                                  fontSize: 18), // Increase text size
                            ),
                            Text(
                              'NIC: ${guide['nic'] ?? 'N/A'}',
                              style: const TextStyle(
                                  fontSize: 18), // Increase text size
                            ),
                            Text(
                              'Telephone: ${guide['telephone'] ?? 'N/A'}',
                              style: const TextStyle(
                                  fontSize: 18), // Increase text size
                            ),
                            Text(
                              'Email: ${guide['email'] ?? 'N/A'}',
                              style: const TextStyle(
                                  fontSize: 18), // Increase text size
                            ),
                            if (guide['letterImageUrl'] != null)
                              InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Image.network(
                                                guide['letterImageUrl']!,
                                                width: 200,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              icon:
                                                  const Icon(Icons.arrow_back),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: const Text(
                                  'View Letter',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Handle approving a guide
                                    if (guide.containsKey('approved') &&
                                        guide['approved'] == true) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Error'),
                                            content: const Text(
                                                'This guide has already been approved.'),
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
                                    } else {
                                      FirebaseFirestore.instance
                                          .collection('guides')
                                          .doc(snapshot.data!.docs[index].id)
                                          .update({'approved': true});
                                    }
                                  },
                                  child: const Text('Approve'),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    // Handle removing a guide
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirmation'),
                                          content: const Text(
                                              'Are you sure you want to remove this guide?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection('guides')
                                                    .doc(snapshot
                                                        .data!.docs[index].id)
                                                    .delete();
                                                Navigator.of(context).pop();
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:travelfreeapp/reusable_widget/bottomnavbar.dart';

class ApprovedHotelListPage extends StatefulWidget {
  const ApprovedHotelListPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ApprovedGuideListPageState createState() => _ApprovedGuideListPageState();
}

class _ApprovedGuideListPageState extends State<ApprovedHotelListPage> {
  final List<DateTime> _markedDates = [];

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    // ignore: unused_local_variable
    final currenthotelEmail = currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 65, 105, 225),
        title: const Text('Date approve List'),
      ),
      body: Column(
        children: [
          _buildCalendar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getDateStream(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No approved hotel found'));
                }
                _markedDates.clear(); // Clear existing marked dates
                // ignore: avoid_function_literals_in_foreach_calls
                snapshot.data!.docs.forEach((hotelDocument) {
                  var hotelDocument2 = hotelDocument;
                  var data = hotelDocument2.data()
                      as Map<String, dynamic>; // Cast data to Map
                  if (data.containsKey('approvedDates')) {
                    var dates = data['approvedDates'];
                    // ignore: avoid_print
                    print(dates);
                    dates.forEach((date) {
                      DateTime startDate = DateTime.parse(date['start']);
                      DateTime endDate = DateTime.parse(date['end']);
                      for (DateTime date = startDate;
                          date.isBefore(endDate.add(const Duration(days: 1)));
                          date = date.add(const Duration(days: 1))) {
                        _markedDates.add(date); // Mark each date as approved
                      }
                    });
                  }
                });
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var hotelDocument = snapshot.data!.docs[index];
                    var selectedDates = hotelDocument['selectedDates'] ?? [];

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: ${hotelDocument['name'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),

                            // Display selected dates with traveler email
                            if (selectedDates.isNotEmpty)
                              ...selectedDates.map((date) {
                                return ListTile(
                                  title: Text(
                                    'Date: ${date['start']} to ${date['end']}',
                                  ),
                                  subtitle: Text(
                                    'Traveler Email: ${date['travelerEmail']}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          // Approve functionality
                                          _approveDate(hotelDocument.id, date);
                                        },
                                        child: const Text('Approve'),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Reject functionality
                                          _rejectDate(hotelDocument.id, date);
                                        },
                                        child: const Text('Reject'),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  @override
  void initState() {
    super.initState();
    // Call a function to fetch data and update _markedDates
    _updateMarkedDates();
  }

  void _updateMarkedDates() async {
    final snapshot = await getDateStream().first;
    _markedDates.clear();
    for (var guideDocument in snapshot.docs) {
      var data =
          guideDocument.data() as Map<String, dynamic>; // Cast data to Map
      if (data.containsKey('approvedDates')) {
        var dates = data['approvedDates'];
        // ignore: avoid_print
        print(dates);
        dates.forEach((date) {
          DateTime startDate = DateTime.parse(date['start']);
          DateTime endDate = DateTime.parse(date['end']);
          for (DateTime date = startDate;
              date.isBefore(endDate.add(const Duration(days: 1)));
              date = date.add(const Duration(days: 1))) {
            _markedDates.add(date); // Mark each date as approved
          }
        });
      }
    }
    setState(() {}); // Trigger a rebuild after updating _markedDates
  }

  Stream<QuerySnapshot> getDateStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currenthotelEmail = currentUser?.email ?? '';
    // ignore: avoid_print
    print('hotel email $currenthotelEmail');
    var stream = FirebaseFirestore.instance
        .collection('hotels')
        .where('approved', isEqualTo: true)
        .where('email', isEqualTo: currenthotelEmail);
    return stream.snapshots();
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: DateTime.now(),
      calendarFormat: CalendarFormat.month,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          // ignore: avoid_print
          final markers = <Widget>[];
          final utcMarkedDates = _markedDates
              .map((date) =>
                  DateTime.utc(date.year, date.month, date.day).toUtc())
              .toList();
          // ignore: avoid_print
          if (utcMarkedDates.contains(day)) {
            markers.add(
              Positioned(
                right: 0,
                left: 4,
                bottom: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  width: 10,
                  height: 10,
                ),
              ),
            );
          }
          return Stack(
            children: markers,
          );
        },
      ),
    );
  }

  Future<void> _approveDate(String hotelId, Map<String, dynamic> date) async {
    try {
      final startDate = date['start'] as String?;
      final endDate = date['end'] as String?;

      if (startDate != null && endDate != null) {
        // print('Approved: $startDate to $endDate');

        // Update the guide document in Firestore
        await FirebaseFirestore.instance
            .collection('hotels')
            .doc(hotelId)
            .update({
          'approvedDates': FieldValue.arrayUnion([
            {
              'start': startDate,
              'end': endDate,
              'travelerEmail': date['travelerEmail'],
            }
          ])
        });

        // Update the marked dates in the calendar
        setState(() {
          for (DateTime date = DateTime.parse(startDate);
              date.isBefore(
                  DateTime.parse(endDate).add(const Duration(days: 1)));
              date = date.add(const Duration(days: 1))) {
            _markedDates.add(date);
            // print('Updated marked dates: $_markedDates');
          }
        });
      } else {
        // ignore: avoid_print
        print('Error: Start date or end date is null');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error approving date: $e');
    }
  }

  Future<void> _rejectDate(String guideId, Map<String, dynamic> date) async {
    // Perform rejection actions
    // ignore: avoid_print
    print('Rejected: ${date['start']} to ${date['end']}');
  }
}

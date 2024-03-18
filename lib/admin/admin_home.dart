import 'package:flutter/material.dart';
import 'package:travelfreeapp/admin/Hotel_add.dart';
import 'package:travelfreeapp/admin/admin_add_place.dart';
import 'package:travelfreeapp/admin/guide_list_page.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomGridItem(
              title: 'Add Place',
              onTap: () {
                // Navigate to AdminAddPlacePage when the button is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminAddPlacePage()),
                );
              },
              gradientColors: [
                Colors.blue.withOpacity(0.55),
                Colors.blue.withOpacity(0.9),
              ],
            ),
            const SizedBox(height: 20), // Adjust the gap between buttons
            CustomGridItem(
              title: 'Add Guide',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GuideListPage()),
                );
              },
              gradientColors: [
                Colors.blue.withOpacity(0.55),
                Colors.blue.withOpacity(0.9),
              ],
            ),
            const SizedBox(height: 20), // Adjust the gap between buttons
            CustomGridItem(
              title: 'Add hotel',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HotelAddPage()),
                );
                // Handle add another action
              },
              gradientColors: [
                Colors.blue.withOpacity(0.55),
                Colors.blue.withOpacity(0.9),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomGridItem extends StatelessWidget {
  const CustomGridItem({
    Key? key,
    required this.title,
    required this.onTap,
    required this.gradientColors,
    this.borderRadius = 16.0,
  }) : super(key: key);

  final String title;
  final VoidCallback onTap;
  final List<Color> gradientColors;
  final double borderRadius;
  final double buttonSize = 130.0; // Define the size of the button

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: Container(
          padding: const EdgeInsets.all(24), // Adjust padding as needed
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

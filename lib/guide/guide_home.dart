import 'package:flutter/material.dart';
import 'package:travelfreeapp/guide/guide_add.dart';

class GuideHomeScreen extends StatelessWidget {
  const GuideHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20), // Adjust the gap between buttons
            CustomGridItem(
              title: 'Add Guide',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GuideAddPage()),
                );
              },
              gradientColors: [
                Colors.green
                    .withOpacity(0.55), // Adjust color scheme for guides
                Colors.green.withOpacity(0.9), // Adjust color scheme for guides
              ],
            ),
            const SizedBox(height: 20), // Adjust the gap between buttons
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

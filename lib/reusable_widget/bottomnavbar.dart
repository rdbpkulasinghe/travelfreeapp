import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:travelfreeapp/screens/emergency%20service.dart';
import 'package:travelfreeapp/screens/guide_page.dart';
import 'package:travelfreeapp/screens/home_page.dart';
import 'package:travelfreeapp/screens/setting_page.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 120, 166, 226),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
        child: GNav(
          backgroundColor: const Color.fromARGB(255, 120, 166, 226),
          color: Colors.white,
          activeColor: Colors.white,
          tabBackgroundColor: const Color.fromARGB(255, 69, 72, 238),
          gap: 5,
          padding: const EdgeInsets.all(16),
          tabs: [
            GButton(
              icon: Icons.home,
              text: 'Home',
              onPressed: () {
                _navigateToHome(context);
              },
            ),
            GButton(
              icon: Icons.person,
              text: 'guide',
              onPressed: () {
                _navigateToGuideSelection(context);
              },
            ),
            GButton(
              icon: Icons.hotel,
              text: 'Accomadation',
              onPressed: () {
                _navigateToAccomadationSelection(context);
              },
            ),
            GButton(
              icon: Icons.emergency,
              text: 'Emergency',
              onPressed: () {
                _navigateToEmergencyService(context);
              },
            ),
            GButton(
              icon: Icons.settings,
              text: 'Settings',
              onPressed: () {
                _navigateToSettingPage(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const HomePage(),
    ));
  }

  void _navigateToGuideSelection(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ApprovedGuideListPage(),
    ));
  }

  void _navigateToAccomadationSelection(BuildContext context) {}

  void _navigateToEmergencyService(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const EmergencyService(),
    ));
  }

  void _navigateToSettingPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const SettingPage(),
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelfreeapp/screens/question_page.dart';

void main() {
  runApp(const QuestionnaireApp());
}

class QuestionnaireApp extends StatelessWidget {
  const QuestionnaireApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 65, 105, 225),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "LOG OUT",
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 27, 8, 8)),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Your journey begins here. Welcome to Travel Free, where we help you create unforgettable memories.",
              style: GoogleFonts.pacifico(
                textStyle: const TextStyle(
                  color: Color.fromARGB(255, 5, 233, 107),
                  fontSize: 36,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuestionPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                padding: const EdgeInsets.fromLTRB(25, 8, 25, 8),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(90), // Adjust the border radius
                ),
              ),
              child: const Text(
                "Start Questionnaire",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black87, // Button text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

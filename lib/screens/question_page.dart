import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travelfreeapp/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    home: QuestionPage(),
  ));
}

class QuestionPage extends StatefulWidget {
  const QuestionPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  late List<Widget> questions = [];
  late Map<String, dynamic> allAnswers = {};

  @override
  void initState() {
    super.initState();
    fetchAnswersFromFirestore();

    // Initialize questions
    questions.addAll([
      QuestionWidget(
        question: 'Name',
        controller: TextEditingController(),
        onAnswered: (value) {
          setState(() {
            allAnswers['Name'] = value;
          });
        },
      ),
      QuestionWidget(
        question: 'Email address',
        controller: TextEditingController(),
        onAnswered: (value) {
          setState(() {
            allAnswers['Email address'] = value;
          });
        },
      ),
      QuestionWidget(
        question: 'Address',
        controller: TextEditingController(),
        onAnswered: (value) {
          setState(() {
            allAnswers['Address'] = value;
          });
        },
      ),
      QuestionWidget(
        question: 'Phone number',
        controller: TextEditingController(),
        onAnswered: (value) {
          setState(() {
            allAnswers['Phone number'] = value;
          });
        },
      ),
      QuestionMultipleChoice(
        question: 'Are you a local or a foreigner?',
        options: const ['Local', 'Foreigner'],
        onAnswered: (value) {
          setState(() {
            allAnswers['Local or Foreigner'] = value;
            if (value.contains('Foreigner')) {
              questions.insert(
                5,
                QuestionWidget(
                  question: 'Passport number',
                  controller: TextEditingController(),
                  onAnswered: (value) {
                    setState(() {
                      allAnswers['Passport number'] = value;
                    });
                  },
                ),
              );
            } else {
              questions.insert(
                5,
                QuestionWidget(
                  question: 'ID',
                  controller: TextEditingController(),
                  onAnswered: (value) {
                    setState(() {
                      allAnswers['ID'] = value;
                    });
                  },
                ),
              );
            }
          });
        },
      ),
      QuestionMultipleChoice(
        question: 'What type of traveler are you?',
        options: const [
          'Solo traveler',
          'Traveling with a partner',
          'Traveling with family',
          'Traveling with friends',
          'Group tours',
        ],
        onAnswered: (value) {
          setState(() {
            allAnswers['Traveler type'] = value;
          });
        },
      ),
      QuestionMultipleChoice(
        question: 'What are your main travel goals?',
        options: const [
          'Adventure and exploration',
          'Relaxation and leisure',
          'Cultural experiences',
          'Nature and wildlife',
          'Historical sites and landmarks',
          'Urban exploration',
          'Family-friendly activities',
        ],
        onAnswered: (value) {
          setState(() {
            allAnswers['Main travel goals'] = value;
          });
        },
      ),
      QuestionMultipleChoice(
        question: 'What type of destinations do you prefer?',
        options: const [
          'Historical and cultural',
          'Natural and scenic',
          'Urban and modern',
          'Beach and coastal',
          'Mountain and adventure',
        ],
        onAnswered: (value) {
          setState(() {
            allAnswers['Destination preferences'] = value;
          });
        },
      ),
      QuestionMultipleChoice(
        question:
            'What type of climate do you prefer for your travels in Sri Lanka? ',
        options: const [
          'Warm and sunny',
          'Hot and humid',
          'Mild and breezy',
          'Cold and cosy',
          'Rainy and tropical',
          'other',
        ],
        onAnswered: (value) {
          setState(() {
            allAnswers['Dietary preferences'] = value;
          });
        },
      ),
      QuestionMultipleChoice(
        question: 'What is your budget?',
        options: const [
          '50000 - 80000',
          '80000 - 100000',
          '100000 - 120000',
          '120000 - 140000',
          '140000 - 160000',
          '160000 - 180000',
          '180000 - 200000',
          '200000 - 250000',
        ],
        onAnswered: (value) {
          setState(() {
            allAnswers['Budget'] = value;
          });
        },
      ),
    ]);
  }

  void fetchAnswersFromFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      try {
        DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
            await FirebaseFirestore.instance
                .collection('answers')
                .doc(userId)
                .get();

        if (documentSnapshot.exists) {
          setState(() {
            allAnswers = documentSnapshot.data()!;
          });
          // ignore: avoid_print
          print('Fetched answers from Firestore: $allAnswers');
        }
      } catch (error) {
        // ignore: avoid_print
        print('Failed to fetch answers data: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Page'),
        backgroundColor: const Color.fromARGB(255, 65, 105, 225),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color.fromARGB(255, 255, 255, 255),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ...questions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final questionWidget = entry.value;
                  return Column(
                    children: [
                      questionWidget,
                      if (index != questions.length - 1)
                        const SizedBox(height: 30),
                    ],
                  );
                }).toList(),
                ElevatedButton(
                  onPressed: saveAnswersToFirestore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 65, 105, 225),
                    padding: const EdgeInsets.fromLTRB(25, 8, 25, 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(90),
                    ),
                  ),
                  child: const Text(
                    'Complete',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void saveAnswersToFirestore() async {
    // Get the currently logged in user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;
      try {
        // Save all answers data to Firestore under a collection named after the user's email
        await FirebaseFirestore.instance
            .collection('answers')
            .doc(userId) // Use user's email as document ID
            .set(allAnswers);

        // Print all the answers
        // ignore: avoid_print
        print('All answers:');
        // ignore: unused_local_variable
        allAnswers.forEach((key, value) {
          // ignore: avoid_print
          print('$key: $value');
        });
        // ignore: avoid_print
        print('Answers saved successfully to Firestore under $userId');

        // Navigate to the HomePage
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } catch (error) {
        // ignore: avoid_print
        print('Failed to save answers data: $error');
      }
    } else {
      // ignore: avoid_print
      print('User is not logged in.');
    }
  }
}

class QuestionWidget extends StatelessWidget {
  final String question;
  final TextEditingController controller;
  final ValueChanged<String> onAnswered;

  const QuestionWidget({
    Key? key,
    required this.question,
    required this.controller,
    required this.onAnswered,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            color: Colors.black, // Change text color to black
            fontSize: 18, // Adjust text size here
          ),
        ),
        const SizedBox(height: 15), // Reduce spacing
        SizedBox(
          width: double.infinity, // Make text field fill available width
          child: TextFormField(
            controller: controller,
            onChanged: onAnswered,
            style: const TextStyle(
              color: Colors.black, // Change text color to black
              fontSize: 14, // Adjust text size of text box
            ),
            decoration: const InputDecoration(
              labelText: 'Answer',
              labelStyle: TextStyle(
                color: Colors.black, // Change text color to black
                fontSize: 14, // Adjust text size of label
              ),
              contentPadding: EdgeInsets.symmetric(
                  vertical: 10, horizontal: 15), // Adjust padding
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class QuestionMultipleChoice extends StatefulWidget {
  final String question;
  final List<String> options;
  final ValueChanged<List<String>> onAnswered;

  const QuestionMultipleChoice({
    Key? key,
    required this.question,
    required this.options,
    required this.onAnswered,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _QuestionMultipleChoiceState createState() => _QuestionMultipleChoiceState();
}

class _QuestionMultipleChoiceState extends State<QuestionMultipleChoice> {
  List<String> selectedValues = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question,
          style: const TextStyle(
            color: Colors.black, // Change text color to black
            fontSize: 18, // Adjust text size here
          ),
        ),
        const SizedBox(height: 15), // Reduce spacing
        Column(
          children: widget.options.map((option) {
            return CheckboxListTile(
              title: Text(
                option,
                style: const TextStyle(
                  color: Colors.black, // Change text color to black
                  fontSize: 14, // Adjust text size of options
                ),
              ),
              value: selectedValues.contains(option),
              onChanged: (value) {
                setState(() {
                  List<String> updatedValues =
                      List.from(selectedValues); // Create a copy
                  if (updatedValues.contains(option)) {
                    updatedValues.remove(option);
                  } else {
                    updatedValues.add(option);
                  }
                  selectedValues = updatedValues; // Update the state variable
                  widget.onAnswered(selectedValues);
                });
              },
              activeColor: Colors.orange,
            );
          }).toList(),
        ),
      ],
    );
  }
}

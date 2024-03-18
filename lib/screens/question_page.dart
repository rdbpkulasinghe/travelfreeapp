import 'package:flutter/material.dart';
import 'package:travelfreeapp/screens/home_page.dart';

void main() {
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
  int currentQuestionIndex = 0;
  final List<Widget> questions = [
    QuestionWidget(
      question: 'Name',
      controller: TextEditingController(),
    ),
    QuestionWidget(
      question: 'Email address',
      controller: TextEditingController(),
    ),
    QuestionWidget(
      question: 'ID',
      controller: TextEditingController(),
    ),
    QuestionWidget(
      question: 'Passport number',
      controller: TextEditingController(),
    ),
    QuestionWidget(
      question: 'Phone number',
      controller: TextEditingController(),
    ),
    QuestionWidget(
      question: 'Address',
      controller: TextEditingController(),
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
        'Culinary experiences',
        'Family-friendly activities',
      ],
      onAnswered: (value) {
        // Handle the selected values
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
        'Business traveler',
        'Other',
      ],
      onAnswered: (value) {
        // Handle the selected values
      },
    ),
    QuestionMultipleChoice(
      question: 'What type of destinations do you prefer?',
      options: const [
        'Historical and cultural',
        'Natural and scenic',
        'Urban and modern',
        'Off-the-beaten-path',
        'Beach and coastal',
        'Mountain and adventure',
        'Others',
      ],
      onAnswered: (value) {
        // Handle the selected values
      },
    ),
    QuestionMultipleChoice(
      question: 'Do you have any dietary restrictions or preferences?',
      options: const [
        'Vegetarian',
        'Vegan',
        'Gluten-free',
        'Allergies',
        'None',
      ],
      onAnswered: (value) {
        // Handle the selected values
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
        // Handle the selected values
      },
    ),
  ];

  void moveToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      // Handle completion, e.g., navigate to the home page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MaterialApp(
            home:
                HomePage(), // Replace HomeScreen with your actual home screen widget
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Page'),
        backgroundColor: const Color.fromARGB(255, 65, 105, 225),
      ),
      body: Container(
        color: const Color.fromARGB(255, 65, 105, 225),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Center(child: questions[currentQuestionIndex]),
              ElevatedButton(
                onPressed: moveToNextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.fromLTRB(25, 8, 25, 8),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(90), // Adjust the border radius
                  ),
                ),
                child: Text(
                  currentQuestionIndex < questions.length - 1
                      ? 'Next Question'
                      : 'Complete',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black87, // Button text color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionWidget extends StatelessWidget {
  final String question;
  final TextEditingController controller;
  const QuestionWidget({
    Key? key,
    required this.question,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 30),
        TextFormField(
          controller: controller,
          style: const TextStyle(
            color: Colors.black,
          ),
          decoration: const InputDecoration(
            labelText: 'Answer',
            labelStyle: TextStyle(
              color: Colors.black,
            ),
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

  void handleCheckboxChanged(String value) {
    setState(() {
      if (selectedValues.contains(value)) {
        selectedValues.remove(value);
      } else {
        selectedValues.add(value);
      }
    });

    widget.onAnswered(selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 20),
        Column(
          children: widget.options.map((option) {
            return CheckboxListTile(
              title: Text(
                option,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              value: selectedValues.contains(option),
              onChanged: (value) {
                handleCheckboxChanged(option);
              },
              activeColor: Colors.orange,
            );
          }).toList(),
        ),
      ],
    );
  }
}

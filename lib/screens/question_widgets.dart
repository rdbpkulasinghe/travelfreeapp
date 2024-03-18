/*import 'package:flutter/material.dart';
import 'package:travelfreeapp/screens/home_page.dart';

class TextQuestion extends StatelessWidget {
  final String question;
  final TextEditingController controller;
  const TextQuestion({
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

class MultipleChoiceQuestion extends StatefulWidget {
  final String question;
  final List<String> options;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onAnswered;

  const MultipleChoiceQuestion({
    Key? key,
    required this.question,
    required this.options,
    required this.selectedValues,
    required this.onAnswered,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MultipleChoiceQuestionState createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion> {
  List<String> selectedValues = [];

  @override
  void initState() {
    super.initState();
    selectedValues = widget.selectedValues;
  }

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

class DropdownQuestion extends StatefulWidget {
  final String question;
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onAnswered;

  const DropdownQuestion({
    Key? key,
    required this.question,
    required this.options,
    required this.selectedValue,
    required this.onAnswered,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DropdownQuestionState createState() => _DropdownQuestionState();
}

class _DropdownQuestionState extends State<DropdownQuestion> {
  String selectedValue = '';

  @override
  void initState() {
    super.initState();
    selectedValue = widget.selectedValue;
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
        DropdownButton<String>(
          value: selectedValue,
          items: widget.options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedValue = value!;
            });
            widget.onAnswered(selectedValue);
          },
        ),
      ],
    );
  }
}

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
  String selectedGender = '';
  String selectedTravelGoal = '';

  void handleGenderAnswer(String value) {
    setState(() {
      selectedGender = value;
    });
  }

  void handleTravelGoalAnswer(String value) {
    setState(() {
      selectedTravelGoal = value;
    });
  }

  List<String> favoriteColorAnswers = [];
  List<String> hobbiesAnswers = [];

  void handleMultipleChoiceAnswer(List<String> values, int questionIndex) {
    setState(() {
      if (questionIndex == 1) {
        favoriteColorAnswers = values;
      } else if (questionIndex == 2) {
        hobbiesAnswers = values;
      }
    });
  }

  void moveToNextQuestion() {
    if (currentQuestionIndex < 4) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      // Handle completion, e.g., navigate to the home page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MaterialApp(
            home: HomePage(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> questions = [
      TextQuestion(
        question: 'Name',
        controller: TextEditingController(),
      ),
      MultipleChoiceQuestion(
        question: 'Favorite Color',
        options: const ['Red', 'Blue', 'Green', 'Yellow'],
        selectedValues: favoriteColorAnswers,
        onAnswered: (value) {
          handleMultipleChoiceAnswer(value, 1);
        },
      ),
      MultipleChoiceQuestion(
        question: 'Hobbies',
        options: const ['Reading', 'Swimming', 'Gaming', 'Traveling'],
        selectedValues: hobbiesAnswers,
        onAnswered: (value) {
          handleMultipleChoiceAnswer(value, 2);
        },
      ),
      MultipleChoiceQuestion(
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
        selectedValues: const [],
        onAnswered: (value) {
          handleMultipleChoiceAnswer(value, 3);
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Page'),
      ),
      body: Container(
        color: const Color.fromARGB(255, 94, 97, 244),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
}**/

/*import 'package:flutter/material.dart';

class ReviewPage extends StatelessWidget {
  final Map<String, dynamic> allAnswers;

  const ReviewPage({Key? key, required this.allAnswers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_print
    print('All Answers: $allAnswers'); // Add this line to print allAnswers

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 65, 105, 225),
        title: const Text('Review Page'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Review Your Answers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            AnswerItem(
              question: 'Name:',
              answer: allAnswers['Name'] ?? 'Not provided',
            ),
            AnswerItem(
              question: 'Email:',
              answer: allAnswers['Email address'] ?? 'Not provided',
            ),
            AnswerItem(
              question: 'Address:',
              answer: allAnswers['Address'] ?? 'Not provided',
            ),
            AnswerItem(
              question: 'Phone number:',
              answer: allAnswers['Phone number'] ?? 'Not provided',
            ),
            AnswerItem(
              question: 'Local or Foreigner:',
              answer: (allAnswers['Local or Foreigner'] != null)
                  ? (allAnswers['Local or Foreigner'].contains('Foreigner')
                      ? 'Foreigner'
                      : 'Local')
                  : 'Not provided',
            ),
            if (allAnswers['Local or Foreigner'] != null &&
                allAnswers['Local or Foreigner'].contains('Foreigner'))
              AnswerItem(
                question: 'Passport number:',
                answer: allAnswers['Passport number'] ?? 'Not provided',
              ),
            if (allAnswers['Local or Foreigner'] != null &&
                allAnswers['Local or Foreigner'].contains('Local'))
              AnswerItem(
                question: 'ID:',
                answer: allAnswers['ID'] ?? 'Not provided',
              ),
            AnswerItem(
              question: 'Main travel goals:',
              answer: (allAnswers['Main travel goals'] != null)
                  ? (allAnswers['Main travel goals'] as List<String>).join(', ')
                  : 'Not provided',
            ),
            AnswerItem(
              question: 'Traveler type:',
              answer: (allAnswers['Traveler type'] != null)
                  ? (allAnswers['Traveler type'] as List<String>).join(', ')
                  : 'Not provided',
            ),
            AnswerItem(
              question: 'Destination preferences:',
              answer: (allAnswers['Destination preferences'] != null)
                  ? (allAnswers['Destination preferences'] as List<String>)
                      .join(', ')
                  : 'Not provided',
            ),
            AnswerItem(
              question: 'Dietary preferences:',
              answer: (allAnswers['Dietary preferences'] != null)
                  ? (allAnswers['Dietary preferences'] as List<String>)
                      .join(', ')
                  : 'Not provided',
            ),
            AnswerItem(
              question: 'Budget:',
              answer: (allAnswers['Budget'] != null)
                  ? (allAnswers['Budget'] as List<String>).join(', ')
                  : 'Not provided',
            ),
          ],
        ),
      ),
    );
  }
}

class AnswerItem extends StatelessWidget {
  final String question;
  final String answer;

  const AnswerItem({
    Key? key,
    required this.question,
    required this.answer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          answer,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}*/

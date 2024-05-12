import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> sendPredictionRequest(
    Map<String, dynamic> requestData) async {
  const String url = 'http://127.0.0.1:8081/predict';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to send prediction request: $e');
  }
}

void main() async {
  Map<String, dynamic> requestData = {
    // Add your request data here
    'key': 'value',
  };

  try {
    Map<String, dynamic> response = await sendPredictionRequest(requestData);
    // ignore: avoid_print
    print(response); // Handle the response data here
  } catch (e) {
    // ignore: avoid_print
    print('Error: $e'); // Handle errors here
  }
}

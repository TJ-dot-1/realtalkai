import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // Test script for OpenRouter Chat Completions
  final openRouterKey = 'YOUR_OPENROUTER_KEY_HERE';
  
  final response = await http.post(
    Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $openRouterKey',
    },
    body: jsonEncode({
      'model': 'gpt-5.4-mini', // or whatever model you are testing
      'messages': [
        {'role': 'system', 'content': 'You are a helpful assistant.'},
        {'role': 'user', 'content': 'Hello!'}
      ],
      'temperature': 0.7,
      'max_tokens': 150,
    }),
  );

  print('Status Code: ${response.statusCode}');
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    print(JsonEncoder.withIndent('  ').convert(jsonResponse));
  } else {
    print('Error:');
    print(response.body);
  }
}
